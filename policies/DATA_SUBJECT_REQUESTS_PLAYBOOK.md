# Data Subject Request Playbook

## Workflow Overview
1. User submits a request via the SPA (`/privacy/requests`) which calls `POST /api/v1/data_subject_requests`.
2. The request is persisted in `data_subject_requests` with a 30-day SLA (`due_at`) and enqueued to `ProcessDataSubjectRequestJob`.
3. Ops/compliance teams monitor the queue, gather required data, and update the status via the admin API or Rails console.
4. Completion (export delivered, erasure confirmed, etc.) is recorded with notes and logged via `Compliance::AuditLogger`.

## Request Types
- **Access (Art. 15)** – Provide a summary/report of data stored about the subject.
- **Export (Art. 20)** – Supply machine-readable files of PHI/PII.
- **Erasure (Art. 17)** – Remove personal data except where retention is legally required.

## SLA & Evidence
- Default SLA = 30 days; document extensions (up to 60 days) in the request notes if complexities arise.
- Store artifacts (email transcripts, export files, deletion confirmations) in your secure evidence repository and reference them in the `notes` field.

## Operational Steps
1. **Triage:** Confirm requestor identity (use MFA + matching email).
2. **Scope:** Identify systems containing the subject’s data (app DB, backups, analytics tools).
3. **Execute:** Run exports or deletion scripts; for erasure, update `DataRetentionPolicy` overrides if necessary.
4. **Communicate:** Provide status updates and final confirmation to the data subject.
5. **Close:** Update the record to `completed` or `rejected` with justification, then archive supporting evidence.

## Automation Hooks
- Extend `ProcessDataSubjectRequestJob` to call out to data warehouses, SaaS APIs, or secure storage buckets where personal data resides.
- Subscribe to `gdpr.request.*` events (see `config/initializers/audit_log_subscriptions.rb`) for alerting/metrics.


