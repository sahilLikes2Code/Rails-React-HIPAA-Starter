# Audit Logging & Evidence Retention Guide

This starter emits HIPAA/SOC 2-relevant events through `Compliance::AuditLogger`, which in turn writes structured JSON to `log/compliance.log`. Ship this file (or stream) to your SIEM / log archive for ≥ 1 year.

## Event Sources
- `Compliance::AuditLogger.log` helper (app/services/compliance/audit_logger.rb)
- PaperTrail versions (PHI access, model lifecycle)
- Rate-limit + security events (Rack::Attack, devise sign-ins) — integrate via `Compliance::AuditLogger.log`

## Retention Expectations
| Evidence Type | Default Retention | Reference |
| --- | --- | --- |
| AuditLog + PaperTrail | 6 years | HIPAA §164.312(b), SOC 2 CC7 |
| SecurityEvent | 1 year | SOC 2 CC7.2 |
| ConsentRecord | 2 years | GDPR Art. 7(1) |

Override periods per environment by setting `DATA_RETENTION_OVERRIDES` (JSON map of model => days). Example: `{"SecurityEvent":730}` keeps security events for 2 years.

## Operational Checklist
1. Configure log shipping (e.g., Vector/Fluent Bit) to forward `log/compliance.log`.
2. Schedule `DataRetentionPolicy.purge_expired` via Sidekiq/Whenever; export logs before deletion.
3. Store quarterly access reviews + purge logs in evidence repository.
4. Test the workflow during audits or tabletop exercises.


