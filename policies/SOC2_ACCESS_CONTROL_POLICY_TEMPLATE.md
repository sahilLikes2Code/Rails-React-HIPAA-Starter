# SOC 2 Access Control Policy Template

> **Use:** Customize this template and have it reviewed by counsel/auditors before relying on it as evidence.

## 1. Purpose
Define a repeatable approach for granting, reviewing, and revoking access to production systems that store customer data in support of Trust Service Criteria (TSC) CC6, CC7, CC8.

## 2. Scope
Applies to all workforce members, contractors, and service accounts with logical or physical access to production infrastructure, source code, or sensitive data.

## 3. Policy Statements
- Access is provisioned based on least privilege and documented business justification.
- All access requests require documented approval (ticket or HR onboarding record).
- MFA is required for privileged accounts and all remote administrative access.
- Access to PHI/PII data stores requires role-based authorization plus break-glass approval.
- Terminated or transferred users have access removed within 24 hours.
- Service accounts rotate credentials at least every 90 days or use short-lived tokens.

## 4. Procedures
1. Requester opens an access ticket specifying systems and justification.
2. Manager + system owner approve electronically.
3. Admin fulfills request and logs completion (ticket, IAM log).
4. Quarterly access reviews compare HR roster, IAM groups, and break-glass logs; variances are remediated within 5 business days.
5. Emergency access is documented, time-bound, and reviewed post-incident.

## 5. Monitoring & Evidence
- IAM audit logs stored ≥ 1 year (meets CC6.3, CC7.2).
- Quarterly access review reports archived in compliance evidence folder.
- Automated alerts for privilege escalations or MFA disablement.

## 6. Roles & Responsibilities
- **Security:** owns policy, executes quarterly reviews.
- **IT/DevOps:** provisions/removes access, maintains logging.
- **Managers:** attest to user need-to-know.

## 7. References
- SOC 2 TSC CC6, CC7, CC8
- HIPAA Security Rule §164.308(a)(3)


