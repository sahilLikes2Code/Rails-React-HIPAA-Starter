# SOC 2 Control Mapping (Starter Coverage)

| Trust Service Criteria | Control Objective | Evidence in Repo | Gaps / Actions |
| --- | --- | --- | --- |
| CC1.1 Governance | Document security policies & roles | `policies/*` templates | Customize + obtain executive approval |
| CC1.3 Vendor Mgmt | Assess third parties | `policies/SOC2_VENDOR_RISK_MANAGEMENT_POLICY_TEMPLATE.md` | Maintain live vendor inventory + risk ratings |
| CC6.2 User Access | Least privilege + provisioning | `SOC2_ACCESS_CONTROL_POLICY_TEMPLATE.md`, Devise MFA setup | Implement automated access reviews + IAM export scripts |
| CC6.6 Network Security | Secure headers, rate limits | `config/initializers/secure_headers.rb`, `rack_attack.rb` | Add infrastructure firewall/WAF configs |
| CC7.2 Logging & Monitoring | Detect anomalous activity | PaperTrail + audit controllers | Centralize logs + alerting (see monitoring task) |
| CC7.4 Incident Response | Respond & report incidents | `SOC2_INCIDENT_RESPONSE_POLICY_TEMPLATE.md` | Run tabletop, store RCA evidence |
| CC8.1 Change Mgmt | Authorize & track changes | `SOC2_CHANGE_MANAGEMENT_POLICY_TEMPLATE.md`, CI setup instructions | Link PR reviews + change tickets automatically |
| CC9.2 Data Management | Retain/dispose data securely | `app/services/data_retention_policy.rb` | Add GDPR/EU retention overrides + deletion proof |
| PI1.2 Processing Integrity | Validate data processing | Automated tests (add references in `README.md`) | Expand test coverage + monitoring dashboards |
| GDPR Art. 7 Consent | Capture/track consent | `ConsentRecord`, `/privacy/consent`, `policies/AUDIT_LOGGING_GUIDE.md` | Customize purposes, connect to email tooling |
| GDPR Art. 15/17/20 Rights | Respond to access/erasure/export | `DataSubjectRequest`, `/privacy/requests`, `ProcessDataSubjectRequestJob` | Integrate with downstream systems, store artifacts |

> Update this matrix as you implement each action. Auditors expect live evidence (tickets, logs, screenshots) linked to each criterion. 


