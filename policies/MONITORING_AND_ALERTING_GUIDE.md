# Monitoring & Alerting Guide

## Signals to Watch
- **Rack::Attack blocks** – automatically sent to `Compliance::AuditLogger` via `config/initializers/rack_attack.rb`.
- **Controller 5xx errors** – captured in `config/initializers/monitoring_hooks.rb` and forwarded when `MONITORING_WEBHOOK_URL` is set.
- **Custom compliance events** – emit through `Compliance::AuditLogger.log` for PHI access anomalies, MFA disablement, or admin actions.

## How to Enable Webhook Delivery
1. Provision a webhook endpoint in your alerting tool (PagerDuty/Slack/etc.).
2. Set `MONITORING_WEBHOOK_URL` in the environment (e.g., Rails credentials or deployment secrets).
3. Verify delivery by tailing `log/compliance.log` and triggering a test event:
   ```ruby
   Compliance::AuditLogger.log(event_type: "monitoring.test", actor: "ops", resource: "webhook", metadata: {})
   ```

## Alert Routing Recommendations
| Event Type | Severity | Destination |
| --- | --- | --- |
| `rack_attack.block` | warning | Security/on-call |
| `incident.*` or `breach.*` | critical | Security + Exec team |
| `http.error` (>=500) | warning | App team |

## Evidence for SOC 2
- Store webhook delivery logs/screenshots in your audit evidence folder.
- Document alert tuning decisions in CAB or risk register.
- Review alert metrics quarterly (false positives, MTTA).


