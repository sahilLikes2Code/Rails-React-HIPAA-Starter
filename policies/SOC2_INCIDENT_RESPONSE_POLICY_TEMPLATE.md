# SOC 2 Incident Response Policy Template

> Align this template with your HIPAA/GDPR obligations and ensure the playbook is tested at least annually.

## 1. Purpose
Provide a structured process for detecting, responding to, and recovering from security incidents to satisfy SOC 2 TSC CC7.4, CC7.5, and HIPAA/GDPR breach notification requirements.

## 2. Scope
Applies to all systems, applications, and personnel involved in storing or processing production data.

## 3. Definitions
- **Security Event:** Observable anomaly that may indicate a threat.
- **Security Incident:** Event that compromises confidentiality, integrity, or availability, or triggers legal notification thresholds.

## 4. Policy Statements
- The incident response team (IRT) must be reachable 24/7.
- All personnel must report suspected incidents within 1 hour via the designated channel.
- Incidents are classified by severity; severity drives communication and escalation paths.
- For incidents involving PHI/PII, legal/compliance must assess HIPAA/HITECH and GDPR notification timelines (60 days / 72 hours).
- Lessons learned and corrective actions are documented after containment.

## 5. Process Overview
1. **Detection:** Alerts from monitoring, user reports, or external notifications.
2. **Triage:** Validate event, assign severity, engage IRT.
3. **Containment:** Isolate affected assets, preserve forensic evidence.
4. **Eradication & Recovery:** Remove threat, restore services, monitor for recurrence.
5. **Post-Incident Review:** Document root cause, control gaps, remediation plan.

## 6. Communication
- Maintain an incident bridge and secure chat.
- Notify executives, customers, regulators per defined SLAs.
- Use pre-approved messaging templates for status updates.

## 7. Testing & Metrics
- Conduct at least one tabletop exercise per year.
- Track MTTA/MTTR, number of incidents by severity, and corrective-action completion.

## 8. References
- SOC 2 TSC CC7.4, CC7.5
- HIPAA Breach Notification Rule (45 CFR §§164.400–414)
- GDPR Articles 33 & 34


