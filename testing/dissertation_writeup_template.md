# Chapter 5 to 7 Write-up Template

## Chapter 5 Test Strategy and Results

### 5.1 Test Strategy

State that the evaluation used a mixed evidence model:

- controlled local negative controls for policy enforcement
- GitHub Actions evidence for governance gates and CI predictability
- Hetzner ArgoCD evidence for live sync, self-heal, and recovery behaviour

State that distributions were analysed using median, IQR, and p95 rather than averages alone.

### 5.2 Governance Results

Use these subsections:

- `GOV-01` Clean-run compliance stability
- `GOV-02` Terraform tagging negative controls
- `GOV-03` Terraform security negative controls
- `GOV-04` Kubernetes policy negative controls
- `GOV-05` PR approval and audit trace controls
- `GOV-06` Drift detection and self-heal

For each subsection:

- cite the run count
- cite the success or block rate
- cite median and p95 duration where relevant
- include one figure or table reference
- state what the result means for governance consistency

### 5.3 Scalability Results

Use these subsections:

- `SCL-01` CI matrix predictability
- `SCL-02` ArgoCD sync latency for app A
- `SCL-03` ArgoCD sync latency for app B
- `SCL-04` Concurrent dual-app updates
- `SCL-05` Scaling response
- `SCL-06` Failure-recovery MTTR

For each subsection:

- cite the sample count
- cite the median, IQR, and p95
- call out any outlier runs
- state whether higher scale introduced instability or only latency variation

### 5.4 Chapter Conclusion

State whether the results show:

- consistent policy enforcement
- reliable auditability
- predictable CI behaviour across cloud lanes
- consistent ArgoCD convergence for both live apps
- any operational constraints that weakened the evidence

## Chapter 6 Analysis

### 6.1 Governance Impact

Answer:

- To what extent did automation enforce governance controls consistently?
- Which controls were preventative rather than detective?
- Did GitHub and OPA reduce manual governance effort?

### 6.2 Scalability and Predictability

Answer:

- Did the pipeline remain predictable as repeated runs accumulated?
- Were delays mostly in CI, GitOps reconciliation, or recovery?
- Did the two-app ArgoCD setup remain operationally manageable?

### 6.3 Limitations and Constraints

Address:

- Hetzner-only live runtime rather than three live clouds
- reliance on GitHub and ArgoCD exported data instead of full observability stack
- any manual steps required for drift, failure, or scale tests
- the difference between vendor-agnostic control logic and provider-specific runtime behaviour

### 6.4 Chapter Conclusion

Link the evidence back to the research question:

- governance improved when controls were codified and executed before deployment
- scalability improved in repeatability and operational predictability, not in eliminating provider/runtime differences

## Chapter 7 Conclusions

### 7.1 Practical Research Conclusions

State directly whether the practical evidence supports the claim that a vendor-agnostic automated pipeline improves governance and scalability.

### 7.2 Key Practical Findings

Write short subsections on:

- governance consistency
- auditability and traceability
- operational predictability
- recovery and self-healing

### 7.3 Limitations

Keep this short. Focus on the remaining gap between the current empirical setup and a fully multi-cloud live deployment study.

### 7.4 Final Conclusion

End with one explicit answer to the dissertation research question based on the measured evidence.
