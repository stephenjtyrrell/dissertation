#!/usr/bin/env python3

from __future__ import annotations

import csv
import math
import os
from collections import defaultdict
from pathlib import Path
from statistics import median


def load_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def parse_float(value: str) -> float | None:
    if value is None:
        return None
    raw = value.strip()
    if not raw:
        return None
    try:
        return float(raw)
    except ValueError:
        return None


def percentile(sorted_values: list[float], target: float) -> float | None:
    if not sorted_values:
        return None
    if len(sorted_values) == 1:
        return sorted_values[0]
    rank = (len(sorted_values) - 1) * target
    lower = math.floor(rank)
    upper = math.ceil(rank)
    if lower == upper:
        return sorted_values[lower]
    lower_value = sorted_values[lower]
    upper_value = sorted_values[upper]
    return lower_value + (upper_value - lower_value) * (rank - lower)


def load_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip('"').strip("'")
    return values


def describe(values: list[float]) -> dict[str, str]:
    numbers = sorted(v for v in values if v is not None)
    if not numbers:
        return {
            "count": "0",
            "min": "",
            "median": "",
            "q1": "",
            "q3": "",
            "iqr": "",
            "p95": "",
            "max": "",
        }

    q1 = percentile(numbers, 0.25)
    q3 = percentile(numbers, 0.75)
    return {
        "count": str(len(numbers)),
        "min": f"{numbers[0]:.0f}",
        "median": f"{median(numbers):.0f}",
        "q1": f"{q1:.0f}" if q1 is not None else "",
        "q3": f"{q3:.0f}" if q3 is not None else "",
        "iqr": f"{(q3 - q1):.0f}" if q1 is not None and q3 is not None else "",
        "p95": f"{percentile(numbers, 0.95):.0f}",
        "max": f"{numbers[-1]:.0f}",
    }


EXPECTED_OUTCOMES = {
    "GOV-01": {"success", "completed", "pass", "passed"},
    "GOV-02": {"blocked"},
    "GOV-03": {"blocked"},
    "GOV-04": {"blocked"},
    "GOV-05": {"approved"},
    "GOV-06": {"healthy", "healed", "self-healed"},
    "SCL-01": {"success", "completed", "pass", "passed"},
    "SCL-02": {"healthy"},
    "SCL-03": {"healthy"},
    "SCL-04": {"healthy"},
    "SCL-05": {"healthy", "scaled"},
    "SCL-06": {"healthy", "recovered"},
}

TEST_GROUPS = {
    "governance": ["GOV-01", "GOV-02", "GOV-03", "GOV-04", "GOV-05", "GOV-06"],
    "scalability": ["SCL-01", "SCL-02", "SCL-03", "SCL-04", "SCL-05", "SCL-06"],
}


def desired_rate(test_id: str, rows: list[dict[str, str]]) -> str:
    expected = EXPECTED_OUTCOMES.get(test_id, set())
    if not rows:
        return ""
    matches = 0
    for row in rows:
        outcome = (row.get("outcome") or "").strip().lower()
        if outcome in expected:
            matches += 1
    return f"{(matches / len(rows)) * 100:.1f}%"


def summarize_runs(rows: list[dict[str, str]]) -> dict[str, list[dict[str, str]]]:
    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[row["test_id"]].append(row)
    return grouped


def render_test_table(group_name: str, grouped_runs: dict[str, list[dict[str, str]]]) -> list[str]:
    lines = [
        f"## {group_name.title()} Tests",
        "",
        "| Test ID | Runs | Desired outcome rate | Median s | IQR s | P95 s | Outcomes |",
        "| --- | ---: | ---: | ---: | ---: | ---: | --- |",
    ]
    for test_id in TEST_GROUPS[group_name]:
        rows = grouped_runs.get(test_id, [])
        durations = [parse_float(row.get("duration_s", "")) for row in rows]
        stats = describe([value for value in durations if value is not None])
        outcomes = ", ".join(sorted({row.get("outcome", "") for row in rows if row.get("outcome", "")})) or "-"
        lines.append(
            f"| {test_id} | {len(rows)} | {desired_rate(test_id, rows) or '-'} | "
            f"{stats['median'] or '-'} | {stats['iqr'] or '-'} | {stats['p95'] or '-'} | {outcomes} |"
        )
    lines.append("")
    return lines


def render_ci_table(job_rows: list[dict[str, str]]) -> list[str]:
    grouped: dict[str, list[float]] = defaultdict(list)
    failures: dict[str, int] = defaultdict(int)
    totals: dict[str, int] = defaultdict(int)

    for row in job_rows:
        cloud = row.get("cloud", "n/a")
        duration = parse_float(row.get("duration_s", ""))
        if duration is not None:
            grouped[cloud].append(duration)
        totals[cloud] += 1
        conclusion = (row.get("conclusion") or "").lower()
        if conclusion not in {"success", "completed", ""}:
            failures[cloud] += 1

    lines = [
        "## CI Matrix",
        "",
        "| Cloud lane | Samples | Median s | IQR s | P95 s | Failure rate |",
        "| --- | ---: | ---: | ---: | ---: | ---: |",
    ]

    for cloud in sorted(grouped.keys() | totals.keys()):
        stats = describe(grouped.get(cloud, []))
        failure_rate = 0.0
        if totals.get(cloud):
            failure_rate = (failures.get(cloud, 0) / totals[cloud]) * 100
        lines.append(
            f"| {cloud} | {totals.get(cloud, 0)} | {stats['median'] or '-'} | "
            f"{stats['iqr'] or '-'} | {stats['p95'] or '-'} | {failure_rate:.1f}% |"
        )

    lines.append("")
    return lines


def render_argocd_table(argocd_rows: list[dict[str, str]]) -> list[str]:
    grouped: dict[str, list[float]] = defaultdict(list)
    healthy: dict[str, int] = defaultdict(int)
    totals: dict[str, int] = defaultdict(int)

    for row in argocd_rows:
        app_name = row.get("app_name", "unknown")
        duration = parse_float(row.get("sync_duration_s", ""))
        if duration is not None:
            grouped[app_name].append(duration)
        totals[app_name] += 1
        if (row.get("health_status") or "").lower() == "healthy":
            healthy[app_name] += 1

    lines = [
        "## ArgoCD Syncs",
        "",
        "| App | Samples | Healthy rate | Median s | IQR s | P95 s |",
        "| --- | ---: | ---: | ---: | ---: | ---: |",
    ]

    for app_name in sorted(grouped.keys() | totals.keys()):
        stats = describe(grouped.get(app_name, []))
        healthy_rate = 0.0
        if totals.get(app_name):
            healthy_rate = (healthy.get(app_name, 0) / totals[app_name]) * 100
        lines.append(
            f"| {app_name} | {totals.get(app_name, 0)} | {healthy_rate:.1f}% | "
            f"{stats['median'] or '-'} | {stats['iqr'] or '-'} | {stats['p95'] or '-'} |"
        )

    lines.append("")
    return lines


def render_rubric(grouped_runs: dict[str, list[dict[str, str]]]) -> list[str]:
    gov01_rate = desired_rate("GOV-01", grouped_runs.get("GOV-01", [])) or "0.0%"
    gov_negatives = [desired_rate(test_id, grouped_runs.get(test_id, [])) or "0.0%" for test_id in ("GOV-02", "GOV-03", "GOV-04")]
    scl_rates = [desired_rate(test_id, grouped_runs.get(test_id, [])) or "0.0%" for test_id in TEST_GROUPS["scalability"]]

    lines = [
        "## Rubric Check",
        "",
        f"- Governance clean-run pass rate (`GOV-01`): {gov01_rate}",
        f"- Governance negative-control detection (`GOV-02` to `GOV-04`): {', '.join(gov_negatives)}",
        f"- Scalability success rates (`SCL-01` to `SCL-06`): {', '.join(scl_rates)}",
        "- Interpret stability from the generated charts using median, IQR, p95, and outlier spread rather than averages.",
        "",
    ]
    return lines


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    config_path = Path(os.environ.get("TESTING_CONFIG", repo_root / "testing" / "config.env"))
    env_file = load_env_file(config_path)

    testing_dir = Path(os.environ.get("TESTING_DIR", repo_root / "testing"))
    evidence_dir = Path(os.environ.get("EVIDENCE_DIR", env_file.get("EVIDENCE_DIR", str(testing_dir / "evidence"))))
    report_dir = Path(os.environ.get("REPORT_DIR", env_file.get("REPORT_DIR", str(testing_dir / "reports" / "generated"))))
    report_dir.mkdir(parents=True, exist_ok=True)

    run_rows = load_rows(evidence_dir / "run_summary.csv")
    job_rows = load_rows(evidence_dir / "ci_job_events.csv")
    argocd_rows = load_rows(evidence_dir / "argocd_events.csv")

    grouped_runs = summarize_runs(run_rows)

    lines: list[str] = [
        "# Dissertation Testing Summary",
        "",
        f"- Run rows: {len(run_rows)}",
        f"- CI job rows: {len(job_rows)}",
        f"- ArgoCD rows: {len(argocd_rows)}",
        "",
    ]
    lines.extend(render_test_table("governance", grouped_runs))
    lines.extend(render_test_table("scalability", grouped_runs))
    lines.extend(render_ci_table(job_rows))
    lines.extend(render_argocd_table(argocd_rows))
    lines.extend(render_rubric(grouped_runs))

    output_path = report_dir / "dissertation_testing_summary.md"
    output_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
