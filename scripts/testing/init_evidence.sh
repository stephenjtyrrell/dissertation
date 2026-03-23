#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_testing_env
init_evidence_layout

printf 'Initialized evidence layout in %s\n' "${EVIDENCE_DIR}"

