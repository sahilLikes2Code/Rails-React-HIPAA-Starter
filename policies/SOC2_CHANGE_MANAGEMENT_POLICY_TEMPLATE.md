# SOC 2 Change Management Policy Template

> Customize for your environment; reviewers expect evidence of consistent execution.

## 1. Purpose
Ensure production changes are authorized, tested, and traceable to support SOC 2 TSC CC8.1, CC8.2, and PI1.2.

## 2. Scope
All code, infrastructure, configuration, and vendor changes that could affect availability, confidentiality, or integrity of customer data.

## 3. Policy Statements
- All changes require a documented change request (ticket, pull request, or change calendar entry).
- Peer review + automated tests must pass before deployment to production.
- High-risk changes require explicit CAB/manager approval and backout plan.
- Emergency changes are documented retroactively within 24 hours.
- Deployment tooling must capture who approved, who deployed, and timestamps.

## 4. Standard Procedure
1. Author submits change request referencing design/docs/tests.
2. Reviewer approves after verifying requirements, risk, and test evidence.
3. CI pipeline enforces unit, security, and lint checks.
4. Deployment occurs via automated pipeline with auditable logs.
5. Post-deployment monitoring verifies success; incidents trigger rollback + RCA.

## 5. Metrics & Evidence
- Change request tickets linked to pull requests.
- CI/CD logs retained ≥ 1 year.
- Monthly change metrics (success rate, emergency change count).

## 6. Roles
- **Change Owner:** prepares change, coordinates testing.
- **Reviewer/CAB:** validates risk and approvals.
- **SRE/DevOps:** maintains tooling, ensures logs are immutable.

## 7. References
- SOC 2 TSC CC8.1, CC8.2, PI1.2
- HIPAA §164.308(a)(1)(ii)(D) Information System Activity Review


