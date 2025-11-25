# HIPAA Compliance Developer Guide

**For developers working on this application**

This guide provides practical, actionable guidelines for maintaining HIPAA compliance when adding features, fixing bugs, or making changes to the application. Follow these guidelines to ensure all code changes maintain compliance with HIPAA Security and Privacy Rules.

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Backend Development Guidelines](#backend-development-guidelines)
3. [Frontend Development Guidelines](#frontend-development-guidelines)
4. [Database & Data Handling](#database--data-handling)
5. [API Design](#api-design)
6. [Authentication & Authorization](#authentication--authorization)
7. [Logging & Monitoring](#logging--monitoring)
8. [Testing Requirements](#testing-requirements)
9. [Common Pitfalls](#common-pitfalls)
10. [Feature Checklist](#feature-checklist)

---

## Core Principles

### 1. **Minimum Necessary Rule**
Only access, use, or disclose the minimum amount of PHI necessary to accomplish the intended purpose.

**Example:**
```ruby
# ❌ BAD: Returning all user data
def show
  render json: @user.as_json
end

# ✅ GOOD: Only return necessary fields
def show
  render json: {
    id: @user.id,
    email: @user.email,
    # Only include PHI if absolutely necessary for this endpoint
  }
end
```

### 2. **Encryption at Rest**
All PHI must be encrypted in the database using Lockbox.

### 3. **Encryption in Transit**
All data transmission must use HTTPS (already enforced in production).

### 4. **Access Control**
Every PHI access must be:
- Authenticated (user is logged in)
- Authorized (user has permission via Pundit policies)
- Audited (logged via Paper Trail)

### 5. **Audit Everything**
All PHI access, creation, modification, and deletion must be logged.

---

## Backend Development Guidelines

### Adding New Models with PHI

**When creating a new model that stores PHI:**

1. **Extend Lockbox and encrypt PHI fields:**
```ruby
# app/models/patient_record.rb
class PatientRecord < ApplicationRecord
  extend Lockbox::Model
  
  # Encrypt all PHI fields
  encrypts :diagnosis, :treatment_notes, :medication_list, :allergies
  
  # Enable audit logging
  has_paper_trail
  
  # Add validations
  validates :patient_id, presence: true
end
```

2. **Create a Pundit policy:**
```ruby
# app/policies/patient_record_policy.rb
class PatientRecordPolicy < ApplicationPolicy
  def show?
    # Only allow access if user is authorized
    user.present? && (record.user_id == user.id || user.has_role?(:admin))
  end
  
  def update?
    show?
  end
  
  class Scope < Scope
    def resolve
      if user&.has_role?(:admin)
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
```

3. **Add to parameter filtering:**
```ruby
# config/application.rb
config.filter_parameters += [
  :diagnosis, :treatment_notes, :medication_list, :allergies
]
```

4. **Add to data retention policy:**
```ruby
# app/services/data_retention_policy.rb
RETENTION_PERIODS = {
  "PatientRecord" => 10.years,  # Adjust based on requirements
  # ...
}
```

### Creating New Controllers

**Always follow this pattern:**

```ruby
# app/controllers/api/v1/patient_records_controller.rb
module Api
  module V1
    class PatientRecordsController < BaseController
      before_action :set_patient_record, only: [:show, :update, :destroy]
      
      def index
        authorize PatientRecord
        @records = policy_scope(PatientRecord)
        render_success({ records: @records })
      end
      
      def show
        authorize @patient_record
        render_success({ record: @patient_record })
      end
      
      def create
        # Validate input first
        validator = PatientRecordParamsValidator.new
        validation_result = validator.call(patient_record_params.to_h)
        
        unless validation_result.success?
          return render_error("Validation failed", 
            status: :unprocessable_entity,
            errors: validation_result.errors.to_h)
        end
        
        @patient_record = PatientRecord.new(validation_result.to_h)
        authorize @patient_record
        
        if @patient_record.save
          render_success({ record: @patient_record }, status: :created)
        else
          render_validation_errors(@patient_record)
        end
      end
      
      private
      
      def set_patient_record
        @patient_record = PatientRecord.find(params[:id])
      end
      
      def patient_record_params
        params.require(:patient_record).permit(:diagnosis, :treatment_notes, ...)
      end
    end
  end
end
```

**Key Requirements:**
- ✅ Use `BaseController` (handles authentication)
- ✅ Use `authorize` and `policy_scope` for authorization
- ✅ Validate input with dry-validation
- ✅ Use `render_success` and `render_error` for consistent responses
- ✅ Never expose internal errors in production

### Input Validation

**Always validate user input using dry-validation:**

```ruby
# app/validators/patient_record_params_validator.rb
class PatientRecordParamsValidator
  include Dry::Validation::Contract
  
  params do
    required(:diagnosis).filled(:string, max_size?: 1000)
    required(:treatment_notes).filled(:string, max_size?: 5000)
    optional(:medication_list).filled(:string)
  end
  
  rule(:diagnosis, :treatment_notes) do
    # XSS prevention
    [:diagnosis, :treatment_notes].each do |field|
      if values[field] && values[field].match?(/[<>]/)
        key(field).failure("contains invalid characters")
      end
    end
  end
end
```

**Validation Rules:**
- ✅ Validate all required fields
- ✅ Set maximum length limits (prevent DoS)
- ✅ Block XSS characters (`<`, `>`)
- ✅ Validate data types
- ✅ Sanitize user input

### Error Handling

**Never expose PHI or internal details in errors:**

```ruby
# ❌ BAD
rescue_from StandardError do |e|
  render_error("Error: #{e.message} - User: #{@user.email}", status: 500)
end

# ✅ GOOD
rescue_from StandardError do |e|
  Rails.logger.error("Error: #{e.class}: #{e.message}")
  render_error("An unexpected error occurred", status: :internal_server_error)
end
```

---

## Frontend Development Guidelines

### Displaying PHI

**When displaying PHI in React components:**

1. **Sanitize HTML content from user input or external sources:**

**When you DON'T need sanitization:**
- Plain text: React automatically escapes content
  ```javascript
  // ✅ Safe - React escapes automatically
  <p>{patient.name}</p>
  <div>{error}</div>
  ```
- Form inputs: Controlled inputs are safe
  ```javascript
  // ✅ Safe
  <input value={data} onChange={handleChange} />
  ```
- JSON display: Safe when using JSON.stringify
  ```javascript
  // ✅ Safe
  <pre>{JSON.stringify(data, null, 2)}</pre>
  ```

**When you DO need sanitization:**
- User-generated HTML content (rich text, comments, notes)
- Content from external sources
- Any time you use `dangerouslySetInnerHTML`

**Use the SafeHtml component (recommended):**
```javascript
// app/javascript/components/SafeHtml.jsx
// This component is already set up in the starter

import SafeHtml from '../components/SafeHtml';

const PatientRecord = ({ record }) => {
  return (
    <div>
      {/* Plain text - no sanitization needed */}
      <h2>{record.patient_name}</h2>
      
      {/* HTML content - use SafeHtml */}
      <SafeHtml content={record.treatment_notes} className="prose" />
    </div>
  );
};
```

**Alternative: Manual sanitization (if needed):**
```javascript
import { sanitizeHtml } from '../utils/sanitize';

const PatientRecord = ({ record }) => {
  const safeNotes = sanitizeHtml(record.treatment_notes);
  return <div dangerouslySetInnerHTML={{ __html: safeNotes }} />;
};
```

2. **Never log PHI to console:**
```javascript
// ❌ BAD
console.log('Patient data:', patientRecord);

// ✅ GOOD
console.log('Patient record loaded:', patientRecord.id);
```

3. **Clear PHI from memory when component unmounts:**
```javascript
useEffect(() => {
  return () => {
    // Clear sensitive data from state
    setPatientData(null);
  };
}, []);
```

### API Calls

**Always use the authenticated API client:**
```javascript
// ✅ GOOD: Use api.js which includes CSRF tokens
import api from '../utils/api';

const fetchPatientRecord = async (id) => {
  try {
    const response = await api.get(`patient_records/${id}`);
    return response.data;
  } catch (error) {
    // Don't log PHI in error messages
    console.error('Failed to fetch record:', id);
    throw error;
  }
};
```

**Never:**
- ❌ Store PHI in localStorage or sessionStorage
- ❌ Include PHI in URL parameters
- ❌ Cache PHI in browser cache without encryption
- ❌ Send PHI via GET requests (use POST/PUT)

### Form Handling

**Always validate on both frontend and backend:**
```javascript
// Frontend validation (UX improvement, not security)
const validateForm = (data) => {
  const errors = {};
  if (!data.email || !data.email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
    errors.email = 'Invalid email format';
  }
  if (!data.password || data.password.length < 12) {
    errors.password = 'Password must be at least 12 characters';
  }
  return errors;
};

// Backend validation (security requirement)
// Always validate in controller using dry-validation
```

---

## Database & Data Handling

### Migrations

**When adding PHI fields:**

```ruby
# db/migrate/xxxxx_add_phi_to_model.rb
class AddPhiToModel < ActiveRecord::Migration[8.0]
  def change
    # Lockbox automatically creates _ciphertext columns
    # Don't create plaintext columns for PHI
    add_column :model_name, :diagnosis_ciphertext, :text
    add_column :model_name, :treatment_notes_ciphertext, :text
    
    # Add indexes for encrypted fields (if needed for queries)
    # Note: You can't index encrypted content directly
    # Consider adding a hash or token field for searching
  end
end
```

**Important:**
- ✅ Never store PHI in plaintext columns
- ✅ Lockbox handles encryption automatically
- ✅ Use `encrypts :field_name` in model, not in migration
- ✅ Add fields to `filter_parameters` in `config/application.rb`

### Queries

**Be careful with encrypted fields:**

```ruby
# ❌ BAD: Can't search encrypted fields directly
PatientRecord.where("diagnosis LIKE ?", "%cancer%")

# ✅ GOOD: Use decrypted values (slower, but secure)
PatientRecord.all.select { |r| r.diagnosis.include?("cancer") }

# ✅ BETTER: Add a searchable hash field if needed
# In migration: add_column :patient_records, :diagnosis_hash, :string
# In model: before_save :set_diagnosis_hash
# def set_diagnosis_hash
#   self.diagnosis_hash = Digest::SHA256.hexdigest(diagnosis.downcase)
# end
```

### Data Export

**When exporting PHI:**

```ruby
# app/services/phi_export_service.rb
class PhiExportService
  def self.export_patient_data(patient_id, user)
    # Log the export
    PaperTrail::Version.create(
      item_type: 'PatientRecord',
      item_id: patient_id,
      event: 'export',
      whodunnit: user.id.to_s,
      object: { exported_at: Time.current }
    )
    
    # Encrypt the export file
    # Send via secure channel
    # Notify user of export
  end
end
```

**Requirements:**
- ✅ Log all PHI exports
- ✅ Encrypt exported files
- ✅ Use secure transmission
- ✅ Implement access controls

---

## API Design

### Endpoints

**Follow RESTful conventions:**

```ruby
# ✅ GOOD: Clear, RESTful endpoints
GET    /api/v1/patient_records          # List (with authorization)
GET    /api/v1/patient_records/:id      # Show (with authorization)
POST   /api/v1/patient_records          # Create (with validation)
PUT    /api/v1/patient_records/:id      # Update (with authorization)
DELETE /api/v1/patient_records/:id      # Delete (admin only)
```

**Never:**
- ❌ Expose PHI in URL parameters
- ❌ Use GET for operations that modify data
- ❌ Return more data than necessary
- ❌ Skip authorization checks

### Response Format

**Always use consistent format:**
```json
{
  "success": true,
  "data": {
    "record": {
      "id": "uuid",
      "diagnosis": "encrypted value",
      "created_at": "2024-01-01T00:00:00Z"
    }
  }
}
```

**Error format:**
```json
{
  "success": false,
  "error": "User-friendly error message",
  "errors": {
    "field_name": ["Validation error"]
  }
}
```

---

## Authentication & Authorization

### Adding New Endpoints

**Always require authentication and authorization:**

```ruby
class NewController < BaseController
  # BaseController already requires authentication
  
  def show
    @record = Record.find(params[:id])
    authorize @record  # ← REQUIRED: Check authorization
    render_success({ record: @record })
  end
end
```

### Policy Creation

**When creating new policies:**

```ruby
# app/policies/your_model_policy.rb
class YourModelPolicy < ApplicationPolicy
  def show?
    # Users can only see their own records
    # Admins can see all
    user.present? && (record.user_id == user.id || user.has_role?(:admin))
  end
  
  def update?
    show?  # Same rules as show
  end
  
  def destroy?
    # Only admins can delete
    user&.has_role?(:admin)
  end
  
  class Scope < Scope
    def resolve
      if user&.has_role?(:admin)
        scope.all
      else
        scope.where(user_id: user.id)  # Users see only their own
      end
    end
  end
end
```

**Key Rules:**
- ✅ Default to denying access
- ✅ Use `policy_scope` for collections
- ✅ Check both ownership and admin role
- ✅ Document any exceptions

---

## Logging & Monitoring

### What to Log

**DO log:**
- ✅ Authentication attempts (success and failure)
- ✅ Authorization failures
- ✅ PHI access (via Paper Trail)
- ✅ Data exports
- ✅ Configuration changes
- ✅ Security events

**DON'T log:**
- ❌ PHI values (use `filter_parameters`)
- ❌ Passwords or tokens
- ❌ Backup codes
- ❌ Encryption keys

### Audit Logging

**Paper Trail automatically logs:**
- ✅ Record creation
- ✅ Record updates
- ✅ Record deletion
- ✅ User who made the change (`whodunnit`)

**Verify your model has:**
```ruby
class YourModel < ApplicationRecord
  has_paper_trail  # ← Required for PHI models
end
```

---

## Testing Requirements

### Security Tests

**Always write tests for:**
1. **Authorization:**
```ruby
# spec/policies/patient_record_policy_spec.rb
describe PatientRecordPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:record) { create(:patient_record, user: user) }
  
  it "allows users to view their own records" do
    expect(PatientRecordPolicy.new(user, record).show?).to be true
  end
  
  it "prevents users from viewing other users' records" do
    expect(PatientRecordPolicy.new(other_user, record).show?).to be false
  end
  
  it "allows admins to view all records" do
    expect(PatientRecordPolicy.new(admin, record).show?).to be true
  end
end
```

2. **Input Validation:**
```ruby
# spec/validators/patient_record_params_validator_spec.rb
describe PatientRecordParamsValidator do
  it "rejects XSS attempts" do
    result = described_class.new.call(
      diagnosis: "<script>alert('xss')</script>"
    )
    expect(result.success?).to be false
    expect(result.errors[:diagnosis]).to be_present
  end
end
```

3. **Encryption:**
```ruby
# spec/models/patient_record_spec.rb
describe PatientRecord do
  it "encrypts PHI fields" do
    record = create(:patient_record, diagnosis: "Test diagnosis")
    expect(record.diagnosis_ciphertext).to be_present
    expect(record.diagnosis_ciphertext).not_to eq("Test diagnosis")
    expect(record.diagnosis).to eq("Test diagnosis")  # Decrypts transparently
  end
end
```

---

## Common Pitfalls

### ❌ Pitfall 1: Exposing PHI in Error Messages
```ruby
# BAD
render_error("Patient #{@patient.email} not found")

# GOOD
render_error("Record not found")
```

### ❌ Pitfall 2: Skipping Authorization
```ruby
# BAD
def show
  @record = Record.find(params[:id])
  render json: @record  # No authorization check!
end

# GOOD
def show
  @record = Record.find(params[:id])
  authorize @record  # ← Required
  render json: @record
end
```

### ❌ Pitfall 3: Not Encrypting New PHI Fields
```ruby
# BAD
class NewModel < ApplicationRecord
  # Forgot to encrypt PHI field
end

# GOOD
class NewModel < ApplicationRecord
  extend Lockbox::Model
  encrypts :phi_field
  has_paper_trail
end
```

### ❌ Pitfall 4: Logging PHI
```ruby
# BAD
Rails.logger.info("User updated: #{@user.first_name} #{@user.last_name}")

# GOOD
Rails.logger.info("User #{@user.id} updated their profile")
```

### ❌ Pitfall 5: Storing PHI in Frontend
```javascript
// BAD
localStorage.setItem('patientData', JSON.stringify(patientRecord));

// GOOD
// Don't store PHI in localStorage/sessionStorage
// Use React state and clear on unmount
```

### ❌ Pitfall 6: Missing Input Validation
```ruby
# BAD
def create
  @record = Record.create(params[:record])  # No validation!
end

# GOOD
def create
  validator = RecordParamsValidator.new
  result = validator.call(params[:record].to_h)
  return render_error(...) unless result.success?
  @record = Record.create(result.to_h)
end
```

---

## Feature Checklist

**Before submitting code that touches PHI, verify:**

### Backend Checklist
- [ ] All PHI fields encrypted with Lockbox (`encrypts :field_name`)
- [ ] Model has `has_paper_trail` for audit logging
- [ ] Pundit policy created and tested
- [ ] Controller uses `authorize` and `policy_scope`
- [ ] Input validation with dry-validation
- [ ] PHI fields added to `filter_parameters` in `config/application.rb`
- [ ] Error messages don't expose PHI
- [ ] All endpoints require authentication
- [ ] Tests written for authorization, validation, and encryption

### Frontend Checklist
- [ ] No PHI stored in localStorage/sessionStorage
- [ ] User input sanitized (DOMPurify for HTML)
- [ ] No PHI in console.log statements
- [ ] PHI cleared from state on component unmount
- [ ] API calls use authenticated `api.js` client
- [ ] No PHI in URL parameters
- [ ] Error messages don't expose PHI

### Database Checklist
- [ ] Migration creates `_ciphertext` columns (not plaintext)
- [ ] Model uses `encrypts` for all PHI fields
- [ ] Indexes added if needed (consider hash fields for search)
- [ ] Data retention policy updated if needed

### Documentation Checklist
- [ ] README updated if adding new features
- [ ] API documentation updated
- [ ] Security implications documented
- [ ] Migration path documented if changing existing PHI handling

---

## Quick Reference

### PHI Fields (Common Examples)
- Names (first, last, middle)
- Addresses
- Phone numbers
- Email addresses
- Dates (birth, admission, discharge)
- Medical record numbers
- SSN
- Diagnosis, treatment notes
- Medication lists
- Lab results
- Insurance information

### Required Gems (Already Installed)
- `lockbox` - Encryption
- `paper_trail` - Audit logging
- `pundit` - Authorization
- `dry-validation` - Input validation
- `devise-two-factor` - MFA
- `secure_headers` - Security headers

### Key Files to Update When Adding PHI
1. Model: Add `encrypts` and `has_paper_trail`
2. Policy: Create `app/policies/your_model_policy.rb`
3. Validator: Create `app/validators/your_model_params_validator.rb`
4. Controller: Use `authorize` and `policy_scope`
5. Config: Add to `filter_parameters` in `config/application.rb`
6. Retention: Add to `DataRetentionPolicy` if needed

---

## Getting Help

**If you're unsure about HIPAA compliance:**

1. **Review existing code** - Look at `User` model and `AuditsController` as examples
2. **Check this guide** - Most common scenarios are covered
3. **Ask the team** - When in doubt, ask before implementing
4. **Review HIPAA_COMPLIANCE_PLAN.md** - For detailed compliance requirements

**Remember:** It's better to ask questions than to create a compliance violation.

---

## Resources

- [HIPAA Compliance Plan](./HIPAA_COMPLIANCE_PLAN.md) - Comprehensive compliance documentation
- [Lockbox Documentation](https://github.com/ankane/lockbox) - Encryption library docs
- [Paper Trail Documentation](https://github.com/paper-trail-gem/paper_trail) - Audit logging docs
- [Pundit Documentation](https://github.com/varvet/pundit) - Authorization library docs

---

