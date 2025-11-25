# Compliance Operations Runbook

## Daily
- Review `log/compliance.log` for high-risk events (`rack_attack.block`, `incident.*`, `gdpr.request.*`).
- Confirm `ProcessDataSubjectRequestJob` queue has no stuck jobs.
- Check monitoring channel fed by `MONITORING_WEBHOOK_URL` for unresolved alerts.

## Weekly
- Export audit evidence (consent changes, access logs, incident tickets) and store in the compliance drive.
- Reconcile new vendors or integrations against `policies/SOC2_VENDOR_RISK_MANAGEMENT_POLICY_TEMPLATE.md`.
- Spot-check `DataRetentionPolicy` overrides and confirm purge job ran successfully (look for `data_retention.purge` events).

## Monthly
- Conduct user access reviews: export IAM/role data, compare to HR roster, document approvals.
- Review open data subject requests and ensure due dates (<30 days) are on track.
- Verify backup restoration + disaster recovery drills are scheduled.

## Quarterly
- Update the compliance matrix (`policies/SOC2_CONTROL_MAPPING.md`) with current evidence links.
- Run an incident response tabletop exercise and capture lessons learned in `SOC2_INCIDENT_RESPONSE_POLICY_TEMPLATE.md`.
- Validate consent purposes with Legal/Marketing; update `ConsentManager.jsx` as needed.

## Annually
- Perform vendor risk reassessments and renew BAAs/DPAs.
- Audit encryption keys, rotate secrets, and update key-management documentation.
- Refresh policy documents, obtain executive sign-off, and circulate to staff.

## Evidence Storage Tips
- Use a dedicated, access-controlled repository (e.g., GDrive, Drata, Secure SharePoint).
- Name artifacts with ISO dates (`2025-11_access-review.pdf`).
- Link artifacts back to ticket IDs inside the matrix/runbook for auditor traceability.

## Tooling Checklist
- **Monitoring:** Ensure `MONITORING_WEBHOOK_URL` points to an active channel.
- **Retention:** Set `DATA_RETENTION_OVERRIDES` per jurisdiction; document approvals.
- **Jobs:** Schedule `DataRetentionPolicy.purge_expired` and `ProcessDataSubjectRequestJob` via Sidekiq/Whenever/Cron.


