# HIPAA Compliance Implementation Plan

## Executive Summary

This document outlines the comprehensive plan to build a HIPAA-compliant Rails + React application. HIPAA requires administrative, physical, technical, and organizational safeguards for Protected Health Information (PHI). While our current project (Amanah Logic) has good foundations in authentication and authorization, significant gaps exist in encryption, audit logging, multi-factor authentication, and formal security policies.

**Estimated Timeline**: 10-14 weeks with a focused team
**Target Compliance**: Full HIPAA Security Rule compliance (45 CFR Parts 160, 164)

---

## Table of Contents

1. [HIPAA Compliance Requirements](#hipaa-compliance-requirements)
2. [Current Project Assessment](#current-project-assessment)
3. [Implementation Roadmap](#implementation-roadmap)
4. [Technical Implementation Details](#technical-implementation-details)
5. [Organizational & Administrative Controls](#organizational--administrative-controls)
6. [Monitoring & Ongoing Compliance](#monitoring--ongoing-compliance)
7. [Resources & References](#resources--references)

---

## HIPAA Compliance Requirements

### Core Pillars

HIPAA Security Rule requires three main types of safeguards:

1. **Administrative Safeguards**: Policies, procedures, workforce training
2. **Physical Safeguards**: Facility security, device controls, backup procedures
3. **Technical Safeguards**: Encryption, access controls, audit logging
4. **Organizational Requirements**: Privacy policies, incident response, business associate agreements

### Key Regulatory References

- **HIPAA Security Rule**: 45 CFR Parts 160, 164 (Subparts A & C)
- **HIPAA Privacy Rule**: 45 CFR Part 164 (Subparts A & E)
- **Breach Notification Rule**: 45 CFR Parts 160, 164 (Subpart D)
- **HITECH Act**: Modified Security Rule with stricter requirements
- **NIST Guidance**: NIST SP 800-66 (HIPAA Security Rule Implementation)

### Protected Health Information (PHI) Definition

Any individually identifiable health information including:
- Names, addresses, phone numbers, email addresses
- Medical record numbers, health conditions, treatment details
- Insurance information, dates (birth, admission, discharge)
- Biometric identifiers, any linked to individual

---

## Current Project Assessment

### ✅ What Amanah Logic Already Has

#### Authentication & Authorization
- **Devise** (~4.9) - User authentication with modules: database_authenticatable, registerable, recoverable, trackable, validatable, rememberable, confirmable
- **Rolify** - Role-based access control
- **Pundit** (~2.3) - Policy-based authorization with fine-grained access control
- **Doorkeeper** - OAuth2 provider with password grant flow
- **Custom Token Authentication** - X-Auth-Token header validation in Authenticable concern

#### API Security
- **Rack-Attack** - Rate limiting configured:
  - Login: 5/minute, 20/hour
  - Signup: 3/hour
  - Password reset: 5/hour
  - OTP verify: 10/15 minutes
  - OTP resend: 3/hour
- **Redis-based rate limiting** - Distributed rate limit store
- **HTTPS enforcement** - force_ssl = true in production
- **Secure cookies** - Configured with secure flags
- **Request/Response filtering** - Sensitive parameters masked in logs

#### Code Quality & Formatting
- **RuboCop** - Ruby code linting with security-focused rules
- **Prettier** - JavaScript/CSS auto-formatting
- **ESLint** - JavaScript linting
- **Husky + Lint-staged** - Pre-commit hooks

#### Infrastructure
- **PostgreSQL** with pgcrypto extension
- **AWS S3** for file storage
- **Active Storage** for file management
- **UUID primary keys** for privacy
- **Rails credentials** system for secrets management

#### Dependencies & Monitoring
- **Honeybadger** (5.13) - Exception monitoring
- **RSpec-Rails** (6.1.0) - Testing framework
- **FactoryBot Rails** - Test data generation

### ❌ Critical Gaps for HIPAA Compliance

#### Encryption (CRITICAL)
- ❌ No database field-level encryption
- ❌ No application-level PHI encryption
- ❌ S3 encryption not explicitly configured
- ❌ Missing attr_encrypted or lockbox gem
- **Impact**: PHI exposed if database compromised

#### Audit Logging (CRITICAL)
- ❌ No PHI access audit logging system
- ❌ No immutable audit trail for sensitive operations
- ❌ No data modification tracking
- ❌ Cannot demonstrate HIPAA compliance for PHI access
- **Impact**: Regulatory violation, cannot prove who accessed what

#### Multi-Factor Authentication (CRITICAL)
- ❌ No MFA/TOTP implementation
- ❌ No SMS or app-based authentication
- ❌ No device trust system
- **Impact**: Single point of failure for authentication

#### Security Controls & Headers (HIGH)
- ❌ Content Security Policy (CSP) disabled
- ❌ Permissions Policy disabled
- ❌ CORS overly permissive (allows *)
- ❌ No API authentication hardening
- **Impact**: Vulnerable to XSS, CSRF, and CORS attacks

#### Data Management (HIGH)
- ❌ No data retention/purging policy
- ❌ No field-level access controls
- ❌ No data classification system
- ❌ No right-to-deletion implementation
- **Impact**: Data sprawl, regulatory non-compliance

#### Infrastructure & Operations (HIGH)
- ❌ No comprehensive backup strategy
- ❌ No disaster recovery plan with RTO/RPO defined
- ❌ No centralized logging (ELK, CloudWatch)
- ❌ No real-time security alerting
- ❌ No incident response procedures documented
- **Impact**: Cannot recover from incidents, no visibility into security events

#### Code Security (HIGH)
- ❌ No static security analysis (Brakeman)
- ❌ No dependency vulnerability scanning (bundler-audit)
- ❌ No secrets detection in CI/CD
- ❌ No input validation framework
- **Impact**: Vulnerable dependencies, exposed secrets

#### Organizational (CRITICAL)
- ❌ No HIPAA Privacy Policy documented
- ❌ No HIPAA Security Policy documented
- ❌ No Incident Response Plan
- ❌ No Business Associate Agreements (BAAs)
- ❌ No workforce security policies
- ❌ No security risk assessment
- ❌ No breach notification procedures
- **Impact**: Core HIPAA requirement violations

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-4) - CRITICAL

**Objectives**: Establish security policies, implement encryption and audit logging, create vendor compliance framework

#### Week 1: Planning & Governance
- [ ] **Designate HIPAA Security Officer** with documented authority
- [ ] **Create Data Dictionary** - Identify all PHI fields in application
- [ ] **Document Security Architecture** - Create security architecture diagram
- [ ] **Identify All Vendors** - AWS, Redis, payment processors, monitoring tools
- [ ] **Create Risk Assessment Template** - Using NIST 800-66 guidance
- [ ] **Assign Compliance Owner** - Executive sponsor for HIPAA compliance

**Deliverables**:
- Security Officer role assignment memo
- PHI data dictionary (spreadsheet with field names, data types, retention periods)
- Vendor inventory with current agreements
- Risk assessment template

#### Week 2-3: Policy Development & Vendor Management
- [ ] **Create HIPAA Privacy Policy**
  - PHI collection and uses
  - Patient rights (access, amendment, accounting)
  - Minimum necessary practices
  - Authorization requirements
  - Breach notification procedures
  
- [ ] **Create HIPAA Security Policy**
  - Administrative, physical, technical safeguards
  - Risk management approach
  - Incident response procedures
  - Workforce responsibilities
  - Sanctions policy
  
- [ ] **Create Incident Response Plan**
  - Detection procedures
  - Investigation process
  - Containment strategies
  - Eradication and recovery
  - Breach notification timeline (60 days)
  - External communication
  
- [ ] **Create Data Retention & Purging Policy**
  - Retention period by data type
  - Automatic purging schedule
  - Secure deletion procedures
  - Verification of deletion
  
- [ ] **Create Business Associate Agreements (BAAs)**
  - AWS S3 data processing terms
  - Redis data processing agreement
  - Payment processor (Stripe) data processing
  - Email service BAA
  - Monitoring tool (Honeybadger, Sentry) BAAs
  
- [ ] **Create Workforce Security Policy**
  - Access authorization procedures
  - Supervision and oversight
  - Termination procedures
  - Role-based access control standards

**Deliverables**:
- Privacy Policy document (reviewed by legal)
- Security Policy document (reviewed by legal)
- Incident Response Plan with procedures
- Data Retention & Purging Policy
- Template BAAs for all vendors (signed)
- Workforce Security Policy

#### Week 4: Technical Foundation
- [ ] **Implement Field-Level Encryption** (Ruby)
  ```bash
  bundle add lockbox
  ```
  - Encrypt all PHI fields (name, email, phone, medical details, etc.)
  - Create encryption key management system
  - Document encrypted fields in data dictionary
  
- [ ] **Implement Audit Logging** (Ruby)
  ```bash
  bundle add paper_trail
  ```
  - Configure Paper Trail for all models containing PHI
  - Create audit dashboard for reviewing access
  - Set up log retention (minimum 6 years)
  - Create automated audit report generator
  
- [ ] **Configure Database Encryption**
  - Enable PostgreSQL pgcrypto extension
  - Document encryption status in schema
  - Create backup encryption procedures
  
- [ ] **Implement Data Retention System**
  - Create scheduled jobs for automated purging
  - Implement soft deletes with timestamps
  - Create verification process for deletion

**Deliverables**:
- Lockbox implemented with all PHI fields encrypted
- Paper Trail audit logging configured
- Database encryption enabled and documented
- Data retention job implementations
- Database backup encryption procedures

**Success Criteria for Phase 1**:
- All policies documented and approved
- All BAAs signed with vendors
- All PHI fields identified and encrypted
- Audit logging active and recording
- Data retention automated

---

### Phase 2: Enhanced Security (Weeks 5-8) - HIGH PRIORITY

**Objectives**: Implement MFA, harden API security, strengthen code security, add monitoring

#### Week 5: Multi-Factor Authentication
- [ ] **Implement MFA for Backend** (Ruby)
  ```bash
  bundle add devise-two-factor rotp
  ```
  - Add TOTP-based MFA to Devise
  - Create admin enforcement of MFA
  - Implement backup codes
  - Create MFA setup/management UI in React
  
- [ ] **Implement MFA for Frontend** (React)
  - Create TOTP QR code scanner component
  - Build MFA setup wizard
  - Add session MFA prompt
  - Implement backup code management
  
- [ ] **Hardware Security Key Support**
  - Research WebAuthn implementation
  - Plan hardware key integration for admin accounts

**Deliverables**:
- TOTP MFA fully implemented and tested
- MFA enforcement policies
- Backup code generation and storage
- MFA setup documentation for users

#### Week 6: API Security Hardening
- [ ] **Static Code Analysis** (Ruby)
  ```bash
  bundle add brakeman --require=false
  ```
  - Add Brakeman to CI/CD pipeline
  - Fix all identified security issues
  - Create security scanning as required build step
  
- [ ] **Dependency Vulnerability Scanning** (Ruby)
  ```bash
  bundle add bundler-audit --require=false
  ```
  - Add bundler-audit to CI/CD
  - Establish vulnerability remediation timeline:
    - Critical: 24-48 hours
    - High: 1 week
    - Medium: 2-4 weeks
    - Low: 1 month
  
- [ ] **Secure HTTP Headers** (Ruby)
  ```bash
  bundle add secure_headers
  ```
  - Implement Content Security Policy (CSP)
  - Add X-Frame-Options, X-Content-Type-Options
  - Configure HSTS
  - Add Permissions-Policy
  
- [ ] **CORS Hardening**
  - Replace wildcard CORS with specific domains
  - Implement origin validation
  - Add CORS pre-flight security
  
- [ ] **Rate Limiting Enhancement**
  - Increase rate limit granularity
  - Add per-endpoint rate limits
  - Implement account lockout after N failed attempts
  - Add monitoring for rate limit evasion patterns

**Deliverables**:
- Brakeman integrated and passing
- Bundler-audit passing with updated gems
- CSP and secure headers configured
- CORS properly restricted
- Rate limiting enhanced

#### Week 7: Code Security & Dependencies
- [ ] **Secrets Detection** (CI/CD)
  ```bash
  # Add to GitHub Actions/CI pipeline
  git-secrets --scan
  ```
  - Implement pre-commit hook for secrets
  - Add secrets scanning to CI/CD
  - Create procedure for exposed secret rotation
  
- [ ] **Input Validation Framework** (Ruby)
  ```bash
  bundle add json-schema dry-validation
  ```
  - Implement JSON schema validation for all API endpoints
  - Add sanitization for user inputs
  - Prevent SQL injection, XSS, command injection
  
- [ ] **Frontend Security** (JavaScript)
  ```bash
  npm install dompurify xss --save
  npm install eslint-plugin-security --save-dev
  ```
  - Add DOMPurify for XSS prevention
  - Configure ESLint security plugin
  - Implement Content Security Policy on frontend
  - Add input sanitization in React components
  
- [ ] **Dependency Audit** (JavaScript)
  - Run npm audit on all packages
  - Update vulnerable packages
  - Document dependency versions and why older versions used (if applicable)

**Deliverables**:
- Secrets scanning in CI/CD and pre-commit
- JSON schema validation on all endpoints
- XSS and injection prevention implemented
- Frontend security scanning active
- All dependencies audited and updated

#### Week 8: Monitoring & Alerting
- [ ] **Centralized Logging** (Infrastructure)
  - Deploy CloudWatch or ELK stack
  - Configure log shipping from application
  - Set minimum 6-year log retention
  - Create log parsing for security events
  
- [ ] **Real-Time Security Alerting**
  - Configure alerts for:
    - Failed authentication attempts (5+ in 15 min)
    - Unauthorized access attempts
    - Mass data export requests
    - Configuration changes
    - Failed MFA attempts
    - Rate limit violations
  
- [ ] **PHI Access Monitoring Dashboard**
  - Create real-time dashboard showing:
    - Who accessed what PHI when
    - Access patterns and anomalies
    - Flagged suspicious access
  
- [ ] **Anomaly Detection Rules**
  - Access outside normal business hours
  - Access to unusual number of records
  - Geographic anomalies
  - Mass data downloads

**Deliverables**:
- Centralized logging infrastructure
- Real-time security alerts configured
- PHI access monitoring dashboard
- Anomaly detection rules deployed

**Success Criteria for Phase 2**:
- MFA enforced for all users
- No Brakeman/bundler-audit vulnerabilities
- CSP and secure headers active
- Secrets detection in place
- Monitoring and alerting operational

---

### Phase 3: Infrastructure & Disaster Recovery (Weeks 9-10) - HIGH PRIORITY

**Objectives**: Establish backup/DR, implement comprehensive testing, create compliance audit procedures

#### Week 9: Backup & Disaster Recovery
- [ ] **Design Backup Strategy**
  - Automated daily encrypted database backups
  - Geographic redundancy (separate AWS regions)
  - Point-in-time recovery capability
  - 6+ month retention period (per HIPAA)
  
- [ ] **Define RTO/RPO**
  - **RTO (Recovery Time Objective)**: 4 hours
  - **RPO (Recovery Point Objective)**: 1 hour
  
- [ ] **Implement Disaster Recovery Plan**
  - Create alternative processing procedures
  - Document failover procedures
  - Create disaster recovery runbook
  - Establish communication procedures
  
- [ ] **Test Backup & Recovery** (Mandatory)
  - Perform full recovery test from backup
  - Document recovery time
  - Test point-in-time recovery
  - Verify data integrity post-recovery
  - Create quarterly testing schedule
  
- [ ] **Database Encryption Configuration**
  - Enable AWS RDS encryption at rest
  - Enable backup encryption
  - Implement key rotation (90-day schedule)
  - Document key management procedures

**Deliverables**:
- Backup automation scripts
- Disaster Recovery Plan document
- RTO/RPO defined and documented
- Successful backup recovery test
- Quarterly testing schedule

#### Week 10: Compliance & Risk Assessment
- [ ] **Comprehensive Risk Assessment**
  - Identify all assets containing PHI
  - Identify threats to each asset
  - Assess vulnerabilities
  - Calculate risk scores
  - Prioritize mitigation strategies
  - Document all findings
  
- [ ] **Create Security Controls Matrix**
  - Map all HIPAA requirements
  - Document implementation status
  - Identify gaps and remediation plans
  - Create remediation timeline
  
- [ ] **Compliance Audit Procedures**
  - Create quarterly self-assessment checklist
  - Define audit scope and procedures
  - Assign audit responsibilities
  - Create audit scheduling
  
- [ ] **Workforce Security Training**
  - Create HIPAA security training curriculum
  - Document initial training requirement
  - Schedule annual refresher training
  - Create training records system
  
- [ ] **Access Control Review Procedures**
  - Create quarterly access review process
  - Document access approval workflow
  - Create termination checklist
  - Implement automated access removal

**Deliverables**:
- Risk assessment report
- Security controls matrix
- Compliance audit procedures
- Training curriculum and schedule
- Access review processes documented

**Success Criteria for Phase 3**:
- Backup/DR tested and working
- Risk assessment completed
- Compliance procedures documented
- Training program launched
- Access controls reviewed and updated

---

### Phase 4: Ongoing Compliance (Week 11+) - CONTINUOUS

**Objectives**: Establish continuous monitoring, regular assessments, and compliance maintenance

#### Monthly Activities
- [ ] **Security Log Review**
  - Review PHI access logs
  - Investigate anomalies
  - Document findings
  
- [ ] **Incident Monitoring**
  - Review security alerts
  - Investigate potential incidents
  - Document response

#### Quarterly Activities
- [ ] **Access Review**
  - Review all user access
  - Remove unnecessary permissions
  - Update role definitions
  - Document changes
  
- [ ] **Compliance Audit**
  - Self-assessment against controls
  - Review policy compliance
  - Identify deviations
  - Create remediation plans
  
- [ ] **Backup Testing**
  - Perform backup recovery test
  - Document results
  - Verify data integrity
  
- [ ] **Security Training**
  - Conduct security awareness session
  - Review incident response
  - Test incident procedures

#### Annually
- [ ] **Risk Assessment**
  - Comprehensive risk review
  - Update threat analysis
  - Assess new vulnerabilities
  - Update risk scores
  
- [ ] **Penetration Testing**
  - Engage third-party tester (external)
  - Test external network
  - Test internal network
  - Test application layer
  - Document findings and remediation
  
- [ ] **Policy Review & Update**
  - Review all security policies
  - Update as needed
  - Communicate changes
  - Get stakeholder approval
  
- [ ] **Disaster Recovery Test**
  - Full simulation of disaster scenario
  - Test failover procedures
  - Document results
  - Update procedures as needed
  
- [ ] **Compliance Certification**
  - Perform comprehensive audit
  - Document compliance status
  - Identify remediation items
  - Create remediation plan

**Ongoing Metrics**:
- 0 critical security vulnerabilities
- <5 high severity vulnerabilities
- 100% HIPAA policy compliance
- <2 security incidents per year
- 100% employee training completion
- Quarterly access reviews completed
- Backup restoration tests passed

---

## Technical Implementation Details

### 1. Field-Level Encryption Implementation

#### Install Lockbox Gem
```ruby
# Gemfile
gem "lockbox"
```

#### Configure Models
```ruby
# app/models/user.rb
class User < ApplicationRecord
  encrypts :first_name, :last_name, :email, :phone_number, :ssn
  encrypts :date_of_birth, :address, :city, :state, :zip
  
  # Automatically decrypt on access
  # Automatically encrypt on save
end

# app/models/medical_record.rb
class MedicalRecord < ApplicationRecord
  encrypts :diagnosis, :treatment, :medication, :allergies
  encrypts :lab_results, :imaging_notes
end
```

#### Key Management
```ruby
# config/initializers/lockbox.rb
Lockbox.key = Rails.application.credentials.lockbox_key
# Or use key rotation:
Lockbox.rotation = {
  old_key: Rails.application.credentials.lockbox_old_key
}
```

### 2. Audit Logging with Paper Trail

#### Install Paper Trail
```ruby
# Gemfile
gem "paper_trail"
```

#### Configure Models
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_paper_trail versions: :revisions, ignore: [:updated_at]
  
  # Customize audit recording
  def paper_trail_event
    if new_record?
      'create'
    elsif destroyed?
      'destroy'
    else
      'update'
    end
  end
end

# app/models/medical_record.rb
class MedicalRecord < ApplicationRecord
  has_paper_trail on: [:create, :update, :destroy]
end
```

#### Create Audit Dashboard
```ruby
# app/controllers/admin/audits_controller.rb
class Admin::AuditsController < ApplicationController
  before_action :authorize_admin!
  
  def index
    @versions = PaperTrail::Version
      .where(item_type: params[:item_type])
      .order(created_at: :desc)
      .page(params[:page])
      .includes(:item)
  end
  
  def show
    @version = PaperTrail::Version.find(params[:id])
  end
  
  def phi_access_log
    # Log all access to PHI fields
    @versions = PaperTrail::Version
      .where("object like ?", "%first_name%")
      .or(PaperTrail::Version.where("object like ?", "%diagnosis%"))
      .order(created_at: :desc)
  end
end
```

### 3. Multi-Factor Authentication

#### Install Devise-Two-Factor
```ruby
# Gemfile
gem "devise-two-factor"
gem "rotp"
gem "qrcode"
```

#### Configure User Model
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :two_factor_backupable
  
  attr_accessor :otp_attempt
  
  # Generate 10 backup codes
  self.backup_code_length = 10
  
  # Generate TOTP secret
  def generate_two_factor_secret
    secret = ROTP::Base32.random
    update(otp_secret: secret)
    secret
  end
  
  def qr_code
    RQRCode::QRCode.new(
      ROTP::TOTP.new(otp_secret, issuer: "YourApp").provisioning_uri(email),
      size: 4,
      level: :m
    )
  end
end
```

#### Create MFA Controllers
```ruby
# app/controllers/users/two_factor_setup_controller.rb
class Users::TwoFactorSetupController < ApplicationController
  def new
    current_user.generate_two_factor_secret
    @qr_code = current_user.qr_code
  end
  
  def create
    if verify_otp(params[:otp_attempt])
      current_user.update(otp_required_for_login: true)
      flash[:notice] = "Two-factor authentication enabled"
      redirect_to user_backup_codes_path
    else
      flash[:alert] = "Invalid code"
      render :new
    end
  end
  
  private
  
  def verify_otp(code)
    ROTP::TOTP.new(current_user.otp_secret).verify(code)
  end
end
```

### 4. Secure HTTP Headers

#### Install Secure Headers Gem
```ruby
# Gemfile
gem "secure_headers"
```

#### Configure Security Headers
```ruby
# config/initializers/secure_headers.rb
SecureHeaders::Configuration.default do |config|
  config.hsts = { max_age: 31536000, include_subdomains: true, preload: true }
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w(no-referrer strict-origin-when-cross-origin)
  
  config.csp = {
    base_uri: %w('self'),
    default_src: %w('self'),
    script_src: %w('self' 'unsafe-inline'),
    style_src: %w('self' 'unsafe-inline'),
    img_src: %w('self' data: https:),
    font_src: %w('self' data:),
    connect_src: %w('self'),
    frame_ancestors: %w('none'),
    form_action: %w('self'),
    upgrade_insecure_requests: []
  }
  
  config.permissions_policy = {
    accelerometer: [],
    camera: [],
    geolocation: [],
    gyroscope: [],
    magnetometer: [],
    microphone: [],
    payment: [],
    usb: []
  }
end
```

### 5. Data Retention & Purging

#### Create Retention Model
```ruby
# app/models/data_retention_policy.rb
class DataRetentionPolicy
  RETENTION_PERIODS = {
    'User' => 7.years,
    'MedicalRecord' => 10.years,
    'Appointment' => 7.years,
    'Invoice' => 7.years,
    'AuditLog' => 6.years
  }
  
  def self.purge_expired
    RETENTION_PERIODS.each do |model_name, retention_period|
      model = model_name.constantize
      expired_records = model.where("created_at < ?", retention_period.ago)
      
      expired_records.each do |record|
        PurgingLog.create(
          record_type: model_name,
          record_id: record.id,
          purged_at: Time.current
        )
        record.really_destroy! # Actually delete (if using soft deletes)
      end
    end
  end
end

# Create Sidekiq job
class DataRetentionJob
  include Sidekiq::Worker
  
  def perform
    DataRetentionPolicy.purge_expired
  end
end

# Schedule with Whenever
# config/schedule.rb
every 1.day, at: '2:00 am' do
  runner 'DataRetentionJob.perform_async'
end
```

### 6. Input Validation

#### Add JSON Schema Validation
```ruby
# Gemfile
gem "json-schema"

# app/validators/json_schema_validator.rb
class JsonSchemaValidator
  def self.validate(data, schema)
    JSON::Validator.validate!(schema, data)
  rescue JSON::Schema::ValidationError => e
    raise ValidationError, e.message
  end
end

# Usage in controller
class UsersController < ApplicationController
  before_action :validate_user_params, only: [:create, :update]
  
  USER_SCHEMA = {
    type: 'object',
    properties: {
      first_name: { type: 'string', minLength: 1, maxLength: 255 },
      last_name: { type: 'string', minLength: 1, maxLength: 255 },
      email: { type: 'string', format: 'email' },
      date_of_birth: { type: 'string', format: 'date' }
    },
    required: ['first_name', 'last_name', 'email']
  }
  
  def create
    JsonSchemaValidator.validate(user_params.to_h, USER_SCHEMA)
    @user = User.create(user_params)
  end
  
  private
  
  def validate_user_params
    JsonSchemaValidator.validate(params[:user].to_h, USER_SCHEMA)
  rescue ValidationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

---

## Organizational & Administrative Controls

### 1. HIPAA Privacy Policy Template

**Required Sections**:
1. Uses and Disclosures of PHI
   - Treatment, payment, healthcare operations
   - Marketing restrictions
   - De-identified data usage
   
2. Patient Rights
   - Right to access PHI
   - Right to request amendment
   - Right to accounting of disclosures
   - Right to restrict disclosure
   - Right to request confidential communication
   - Right to complain about privacy practices
   
3. Minimum Necessary Standard
   - How we limit access to minimum necessary PHI
   - Request evaluation procedures
   
4. Authorization & Consent
   - When authorization required
   - How authorization documented
   - Duration of authorization
   
5. Business Associate Requirements
   - How BAs handle PHI
   - Subcontractor requirements
   - BA data breach procedures
   
6. Breach Notification
   - Breach definition
   - Notification timeline (60 days)
   - Breach notification content
   - Regulatory notifications (HHS, media)
   
7. Security Safeguards
   - Overview of technical, physical, administrative controls
   - Encryption and access controls
   - Monitoring and audit logging
   
8. Amendments & Changes
   - How to request amendment
   - Our response procedures
   
9. Complaint Procedures
   - How to file complaint
   - Our investigation process
   - Non-retaliation assurance

**Location**: /app/views/public/privacy_policy.html.erb

### 2. HIPAA Security Policy Template

**Required Sections**:
1. Purpose and Scope
   - Applicability to all PHI and ePHI
   - All employees, contractors, vendors
   
2. Administrative Safeguards
   - Security Officer designation
   - Risk assessment procedures
   - Incident response procedures
   - Contingency planning
   - Workforce training requirements
   
3. Physical Safeguards
   - Facility access controls
   - Workstation security requirements
   - Device and media controls
   - Backup procedures
   
4. Technical Safeguards
   - Access controls (authentication, authorization)
   - Audit logging requirements
   - Encryption standards
   - Transmission security requirements
   - Integrity controls
   
5. Sanctions Policy
   - Violations and consequences
   - Disciplinary procedures
   - Termination procedures
   
6. Compliance & Monitoring
   - Audit procedures
   - Compliance monitoring
   - Regular risk assessments (minimum annually)

**Location**: /docs/HIPAA_SECURITY_POLICY.md

### 3. Business Associate Agreement (BAA) Checklist

**Required BAA Provisions**:
- [ ] BA will comply with HIPAA Security Rule
- [ ] BA will use PHI only as permitted by contract
- [ ] BA will restrict subcontractors to same terms
- [ ] BA will report security incidents/breaches immediately
- [ ] BA will cooperate with investigations
- [ ] BA allows covered entity audit rights
- [ ] BA returns/destroys PHI upon termination
- [ ] BA cannot use PHI for own marketing
- [ ] BA implements required safeguards
- [ ] BA maintains audit logs per requirements
- [ ] BA certifies subcontractor compliance
- [ ] BA indemnifies covered entity
- [ ] Termination procedures for breach
- [ ] Data retention after termination (45 days minimum)

**Vendors Requiring BAAs**:
- AWS (data storage, compute)
- Redis (caching PHI?)
- Stripe (payment processing with PHI)
- Email service (if handling PHI)
- Monitoring tools (Honeybadger, Sentry)
- Any external contractor or consultant

**Location**: /docs/business_associate_agreements/

### 4. Incident Response Plan Template

**Plan Contents**:

#### Detection & Analysis
- Log monitoring procedures
- Incident detection rules
- Initial assessment process
- Escalation criteria
- Notification of security team

#### Investigation
- Forensic procedures
- Evidence collection and preservation
- Access log review
- System log analysis
- Timeline reconstruction

#### Containment
- Immediate mitigation steps
- System isolation procedures
- Credential revocation
- Malware removal procedures
- Communication containment

#### Eradication
- Root cause analysis
- System hardening
- Vulnerability patching
- Access control updates
- Integrity verification

#### Recovery
- System restoration procedures
- Data recovery (from backups)
- Testing and verification
- Normal operations resumption

#### Post-Incident
- Root cause documentation
- Remediation actions
- Process improvements
- Staff notification (if required)
- Breach notification (if required)

#### Breach Notification Requirements
- **If PHI exposed**: Notify affected individuals within 60 days
- **Content of notification**:
  - Description of breach
  - Types of information involved
  - Steps individuals should take
  - What we're doing to prevent recurrence
  - Contact information for questions
  - Credit monitoring offer (if financial info)
  
- **Regulatory notifications**:
  - If 500+ affected: Notify HHS and media
  - Otherwise: Notify HHS annually in December

#### Incident Log Template
```
Incident ID: [unique ID]
Date Discovered: [date/time]
Reported By: [name]
Incident Type: [breach/unauthorized access/loss/etc]
PHI Involved: [yes/no, details]
Systems Affected: [list]
Initial Assessment: [findings]
Severity Level: [critical/high/medium/low]
Assigned To: [security officer]
Status: [open/investigating/contained/resolved]
Root Cause: [findings]
Remediation Actions: [list]
Verification: [proof of fix]
Notification Sent: [yes/no, to whom]
Closed Date: [date]
```

**Location**: /docs/INCIDENT_RESPONSE_PLAN.md

### 5. Data Retention & Purging Policy

**Policy Contents**:

#### Retention Periods by Data Type
```
User Account Data:
- Active accounts: Retain while account active + 7 years after termination
- Inactive accounts: 7 years from last access

Medical Records:
- Create: 10 years after last encounter
- Update: 10 years from last update
- Delete: No earlier than 10 years

Audit Logs:
- All audit logs: Minimum 6 years (per HIPAA)
- PHI access logs: 6+ years
- System logs: 2+ years
- Security events: 3+ years

Payment Records:
- Invoices: 7 years (per IRS)
- Receipts: 7 years
- Credit card data: Immediately (never store)

Temporary Data:
- Session data: 30 days
- Cache: 1 day or on session end
- Logs (non-audit): 90 days
```

#### Purging Procedures
1. **Scheduled Purging**
   - Automated daily at 2 AM
   - Based on retention schedule
   - Immutable log of purge actions
   
2. **Secure Deletion**
   - Cryptographic erasure (preferred)
   - Overwrite with zeros
   - Multi-pass deletion for sensitive data
   
3. **Verification**
   - Verify deletion complete
   - Spot-check backup exclusion
   - Document purge verification
   
4. **Emergency Purging**
   - Manual purging when necessary
   - Documented authorization
   - Expedited notification to affected parties

**Location**: /docs/DATA_RETENTION_POLICY.md

### 6. Workforce Security Policy

**Policy Contents**:

#### Access Authorization
- **Job Roles Define Access**
  - PHI access determined by job function
  - Minimum necessary principle enforced
  - No default access granted
  
- **Authorization Workflow**
  - Manager requests access
  - Security officer approves
  - Access provisioned with time limit
  - Access reviewed quarterly
  
- **Access Levels**
  - View only: Can view PHI, cannot export
  - Edit: Can view and modify
  - Delete: Can delete records (rare)
  - Admin: Full system access with audit logging

#### Supervision & Monitoring
- **Day-to-Day Supervision**: Managers responsible for workforce adherence
- **Access Monitoring**: Automated alerts for suspicious access patterns
- **Audit Reviews**: Monthly review of PHI access logs
- **Performance Reviews**: Include security compliance assessment

#### Termination Procedures
- **Upon Termination Notice**:
  - Remove system access
  - Collect company property
  - Return badges/keys
  - Revoke API keys
  - Disable email
  - Archive files
  
- **Timeline**: Must complete within 24 hours of termination
- **Documentation**: Maintain termination checklist
- **Verification**: Confirm all access removed

#### Sanctions Policy
- **Minor Violations**
  - Verbal warning
  - Documented training
  - Written warning
  
- **Serious Violations**
  - Suspension
  - Disciplinary meeting
  - Documented remediation plan
  
- **Critical Violations** (unauthorized PHI access, data theft, etc.)
  - Immediate termination
  - Legal action (if applicable)
  - Law enforcement notification (if crime)
  - Affected party notification (if breach)

**Location**: /docs/WORKFORCE_SECURITY_POLICY.md

---

## Monitoring & Ongoing Compliance

### Monthly Compliance Activities

#### Security Log Review (1st Monday)
```ruby
# app/services/security_log_reviewer.rb
class SecurityLogReviewer
  def self.monthly_review
    phi_accesses = PaperTrail::Version
      .where("created_at > ?", 1.month.ago)
      .where(item_type: ['User', 'MedicalRecord', 'Appointment'])
    
    suspicious_patterns = detect_suspicious_access(phi_accesses)
    generate_monthly_report(phi_accesses, suspicious_patterns)
  end
  
  private
  
  def self.detect_suspicious_access(accesses)
    # Detect:
    # - High volume access (>100 records/hour)
    # - Off-hours access
    # - Unusual user combinations
    # - Mass exports
  end
  
  def self.generate_monthly_report(accesses, patterns)
    report = {
      total_phi_accesses: accesses.count,
      unique_users: accesses.pluck(:whodunnit).uniq.count,
      suspicious_patterns: patterns,
      incidents_identified: 0
    }
    
    SecurityLogReview.create(report)
  end
end

# Run via Sidekiq on 1st Monday
class MonthlySecurityReviewJob
  include Sidekiq::Worker
  
  def perform
    SecurityLogReviewer.monthly_review
  end
end
```

### Quarterly Compliance Activities

#### Access Control Review (Month 3, 6, 9, 12)
```ruby
# app/services/access_reviewer.rb
class AccessReviewer
  def self.quarterly_review
    users = User.all
    
    users.each do |user|
      current_access = user.roles
      needed_access = determine_needed_access(user)
      
      if current_access != needed_access
        create_access_modification_request(user, current_access, needed_access)
      end
      
      AuditLog.create(
        event: 'quarterly_access_review',
        user_id: user.id,
        details: { current: current_access, needed: needed_access }
      )
    end
  end
  
  private
  
  def self.determine_needed_access(user)
    # Based on job function, department, manager approval
  end
  
  def self.create_access_modification_request(user, current, needed)
    # Auto-request removal of unnecessary roles
    # Require manager confirmation
  end
end
```

#### Backup Recovery Test (Month 3, 6, 9, 12)
```ruby
# app/services/backup_recovery_tester.rb
class BackupRecoveryTester
  def self.test_recovery
    # 1. Get latest backup
    backup = LatestBackup.get
    
    # 2. Restore to staging environment
    staging_db = Database.new('staging')
    staging_db.restore_from(backup)
    
    # 3. Verify data integrity
    original_count = Database.production.users.count
    staging_count = staging_db.users.count
    
    if original_count == staging_count
      # 4. Test queries work
      staging_db.medical_records.count
      staging_db.appointments.count
      
      # 5. Log test results
      BackupTest.create(
        tested_at: Time.current,
        backup_date: backup.date,
        status: 'success',
        recovery_time_minutes: Time.current - backup.date,
        data_verified: true
      )
    else
      alert_security_team('Backup integrity check failed')
    end
  end
end
```

### Annual Compliance Activities

#### Comprehensive Risk Assessment
```ruby
# docs/RISK_ASSESSMENT_TEMPLATE.md
Risk Assessment Template:
1. Asset Inventory
   - All systems containing PHI
   - Data storage locations
   - Processing systems
   
2. Threat Analysis
   - Unauthorized access
   - Data breaches
   - Natural disasters
   - System failures
   - Human error
   - Malicious insiders
   
3. Vulnerability Assessment
   - Known vulnerabilities
   - Configuration weaknesses
   - Security control gaps
   
4. Risk Calculation
   - Probability × Impact = Risk
   - Rank all risks
   
5. Mitigation Plans
   - For each high/critical risk
   - Timeline for remediation
   - Owner assignment
   
6. Documentation
   - Store in /docs/annual_risk_assessments/
   - Board-level approval required
```

#### Annual Penetration Testing
```
Penetration Test Scope:
- External network assessment
- Web application testing
- Internal network testing
- Physical security assessment
- Social engineering assessment
- Wireless security testing

Reporting Requirements:
- Executive summary
- Detailed findings
- Severity ratings (critical/high/medium/low)
- Proof of concept
- Remediation recommendations
- Timeline: Critical findings within 48 hours

Success Criteria:
- 0 critical/high vulnerabilities remaining
- Fix verification performed
- Report filed with board
```

#### Annual Policy Review
```
Policy Review Checklist:
- [ ] Privacy Policy - Legal review
- [ ] Security Policy - Security team review
- [ ] Incident Response - Test against latest incidents
- [ ] Data Retention - Confirm still compliant
- [ ] Workforce Security - Update for new roles
- [ ] Business Associate Agreements - Renew/update
- [ ] Access Control Policy - Update for new systems
- [ ] Training Program - Assess effectiveness
- [ ] Board approval
- [ ] Communicate updates to workforce
```

### Compliance Metrics Dashboard

```ruby
# app/services/compliance_metrics.rb
class ComplianceMetrics
  def self.dashboard
    {
      security: {
        critical_vulnerabilities: find_unresolved_vulnerabilities('critical').count,
        high_vulnerabilities: find_unresolved_vulnerabilities('high').count,
        failed_security_tests: run_security_tests.failures,
        backup_tests_passed: BackupTest.where("created_at > ?", 1.year.ago).passed.count
      },
      access: {
        users_with_mfa: User.where(otp_required_for_login: true).count,
        access_reviews_overdue: AccessReview.where("due_date < ?", Date.today).count,
        unauthorized_access_attempts: SecurityAlert.where(type: 'unauthorized_access').count
      },
      operations: {
        security_incidents_this_year: SecurityIncident.where("created_at > ?", 1.year.ago).count,
        data_breaches_this_year: DataBreach.where("created_at > ?", 1.year.ago).count,
        audit_log_integrity_verified: AuditLog.integrity_verified?,
        disaster_recovery_rpo_met: BackupTest.recent.all? { |t| t.data_age < 1.hour }
      },
      compliance: {
        training_completion_rate: calculate_training_completion,
        policy_review_current: policies_reviewed_this_year?,
        pentest_current: penetration_test_within_last_year?,
        risk_assessment_current: risk_assessment_within_last_year?
      }
    }
  end
end
```

---

## Implementation Dependencies & Technology Stack

### Ruby Gems to Add
```ruby
# Encryption
gem "lockbox"

# Audit Logging
gem "paper_trail"

# Multi-Factor Authentication
gem "devise-two-factor"
gem "rotp"
gem "qrcode"

# Security Scanning
gem "brakeman", require: false
gem "bundler-audit", require: false
gem "secure_headers"

# Input Validation
gem "json-schema"
gem "dry-validation"

# Monitoring (if not using Honeybadger)
gem "sentry-rails"
gem "sentry-sidekiq"

# Background Jobs (if adding Sidekiq)
gem "sidekiq"
gem "whenever", require: false

# API Security
gem "rack-attack"  # Already have

# Additional Security
gem "strip_attributes"
gem "email_validator"
```

### JavaScript/React Packages
```json
{
  "devDependencies": {
    "eslint-plugin-security": "^1.7.1",
    "@snyk/cli": "latest",
    "npm-audit": "latest"
  },
  "dependencies": {
    "dompurify": "^3.0.0",
    "xss": "^1.0.14"
  }
}
```

### Infrastructure Components
- PostgreSQL with pgcrypto extension
- Redis (for rate limiting, caching)
- AWS S3 (file storage)
- AWS RDS (database with encryption)
- AWS CloudWatch or ELK (centralized logging)
- GitHub Actions or equivalent (CI/CD pipeline)

---

## Success Criteria & Compliance Checklist

### Phase 1 Success Criteria
- [ ] Security Officer designated and documented
- [ ] All PHI fields identified in data dictionary
- [ ] All policies drafted and under legal review
- [ ] All vendors identified and BAA status tracked
- [ ] Lockbox encryption implemented for all PHI fields
- [ ] Paper Trail audit logging operational
- [ ] Database encryption enabled
- [ ] Data retention automation configured
- [ ] No critical security findings in code review

### Phase 2 Success Criteria
- [ ] MFA enabled for all users
- [ ] Brakeman security scan passing
- [ ] Bundler-audit passing
- [ ] CSP and secure headers deployed
- [ ] CORS properly restricted
- [ ] Secrets scanning active in CI/CD
- [ ] Input validation on all endpoints
- [ ] Frontend security scanning enabled
- [ ] Centralized logging operational
- [ ] Security alerts configured and tested

### Phase 3 Success Criteria
- [ ] Backup/DR procedures documented and tested
- [ ] RTO/RPO defined and achievable
- [ ] Quarterly access reviews scheduled
- [ ] Risk assessment completed
- [ ] Security controls matrix created
- [ ] Workforce training program launched
- [ ] Incident response procedures tested

### Phase 4 Success Criteria (Ongoing)
- [ ] Monthly log reviews completed
- [ ] 0 critical security vulnerabilities
- [ ] <5 high severity vulnerabilities
- [ ] 100% HIPAA policy compliance
- [ ] Quarterly compliance audits completed
- [ ] Annual penetration testing completed
- [ ] Annual risk assessment updated
- [ ] 100% employee training completion

---

## Resources & References

### Regulatory Documents
- **HIPAA Security Rule**: https://www.hhs.gov/hipaa/for-professionals/security/index.html
- **HIPAA Privacy Rule**: https://www.hhs.gov/hipaa/for-professionals/privacy/index.html
- **Breach Notification Rule**: https://www.hhs.gov/hipaa/for-professionals/breach-notification-rule/index.html
- **NIST SP 800-66**: https://csrc.nist.gov/publications/detail/sp/800-66/rev-1/final

### Implementation Guides
- **HHS Guidance**: https://www.hhs.gov/hipaa/for-professionals/index.html
- **HealthIT.gov**: https://www.healthit.gov/hipaa
- **OCR Audit Protocol**: https://www.hhs.gov/ocr/privacy/hipaa/enforcement/audit/index.html
- **CMS Risk Assessment Tools**: https://www.cms.gov/

### Technology Resources
- **Lockbox Documentation**: https://github.com/ankane/lockbox
- **Paper Trail Documentation**: https://github.com/paper-trail-gem/paper_trail
- **Devise Two-Factor**: https://github.com/tinybike/devise-two-factor
- **Brakeman**: https://brakemanscanner.org/
- **OWASP Security Resources**: https://owasp.org/

### Security Best Practices
- **NIST Cybersecurity Framework**: https://www.nist.gov/cyberframework
- **SANS Security Guidelines**: https://www.sans.org/
- **CWE/OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **HIPAA Security Rule Implementation**: https://csrc.nist.gov/publications/detail/sp/800-66/rev-1/final

---

## Governance & Oversight

### Compliance Governance Structure
```
Board of Directors
    ↓
Chief Compliance Officer / HIPAA Privacy Officer
    ↓
Security Officer (Designated)
    ├── Privacy Team
    ├── Security Team
    ├── IT Operations
    └── Legal & Compliance
```

### Approval Authorities
- **Policy Approval**: Board of Directors (annual)
- **Risk Decisions**: Chief Compliance Officer + Security Officer
- **Incident Response**: Security Officer + Privacy Officer + Legal
- **Access Decisions**: Department Manager + Security Officer
- **System Changes**: Chief Technology Officer + Security Officer + Privacy Officer

### Escalation Procedures
- **Critical Security Incident**: Notify CEO, Board, and Legal immediately
- **Data Breach**: Notify Privacy Officer, Legal, and Insurance within 24 hours
- **Regulatory Inquiry**: Route to Chief Compliance Officer and Legal
- **Suspected Insider Threat**: Notify HR, Security, and Legal

---

## Document Repository Structure

```
/docs/
├── HIPAA_COMPLIANCE_PLAN.md (this file)
├── HIPAA_SECURITY_POLICY.md
├── HIPAA_PRIVACY_POLICY.md
├── INCIDENT_RESPONSE_PLAN.md
├── DATA_RETENTION_POLICY.md
├── WORKFORCE_SECURITY_POLICY.md
├── RISK_ASSESSMENT_TEMPLATE.md
├── business_associate_agreements/
│   ├── AWS_BAA.pdf (signed)
│   ├── Stripe_BAA.pdf (signed)
│   ├── Redis_BAA.pdf (if applicable)
│   └── [Other vendor BAAs]
├── annual_audits/
│   ├── 2024_risk_assessment.md
│   ├── 2024_penetration_test_report.pdf
│   ├── 2024_compliance_audit.md
│   └── [Annual audit records]
├── incident_logs/
│   ├── incident_register.csv
│   └── [Incident documentation]
├── training/
│   ├── HIPAA_Training_Curriculum.md
│   ├── training_records.csv
│   └── [Training materials]
└── access_control/
    ├── access_matrix.xlsx
    ├── termination_checklist.md
    └── [Access approval records]
```

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2024-11-14 | 1.0 | Initial comprehensive HIPAA compliance plan | Security Team |
| | | | |

---

## Approval Sign-Off

- [ ] Security Officer: _________________ Date: _______
- [ ] Chief Compliance Officer: _________________ Date: _______
- [ ] Legal Counsel: _________________ Date: _______
- [ ] Chief Technology Officer: _________________ Date: _______
- [ ] Board of Directors: _________________ Date: _______

---

**Document Classification**: Confidential - Internal Use Only
**Last Updated**: November 14, 2024
**Next Review Date**: November 14, 2025
