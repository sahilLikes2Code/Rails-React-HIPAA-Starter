# Rails + React HIPAA Starter

A comprehensive starter template for building HIPAA-compliant Rails + React applications.

**Important:** This starter has **HIPAA compliance features enabled by default** on the User model (encryption, audit logging, MFA). However, you must:
- Customize PHI fields for your specific models
- Add encryption/audit logging to other models containing PHI
- Create and customize policies
- Sign Business Associate Agreements
- Configure production security

See the [HIPAA Compliance Checklist](#hipaa-compliance-checklist) for complete requirements.

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/sahilLikes2Code/Rails-React-HIPAA-Starter my_app_name
cd my_app_name

# 2. Update database config (edit config/database.yml with your PostgreSQL credentials)

# 3. (Optional) Customize seed data by creating a .env file
# See CONFIGURATION.md for all available options
cp .env.example .env  # If .env.example exists, or create .env manually

# 4. Run setup (installs dependencies, sets up database, creates credentials)
# IMPORTANT: This must be run before bin/dev
bin/setup

# 5. Start development server
bin/dev
```

That's it! Visit http://localhost:3000

**Important:** 
- Always run `bin/setup` first. It installs Ruby gems (`bundle install`) and JavaScript packages (`yarn install`), which are required before starting the server.
- The setup script will automatically create `credentials.yml.enc` and `master.key` if they don't exist.
- Make sure to update `config/database.yml` with your PostgreSQL credentials before running `bin/setup`.
- See [CONFIGURATION.md](./CONFIGURATION.md) for customization options.

## 📋 Detailed Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/sahilLikes2Code/Rails-React-HIPAA-Starter my_app_name
cd my_app_name
```

### Step 2: Configure Database

Edit `config/database.yml` with your PostgreSQL credentials:

```yaml
development:
  <<: *default
  database: my_app_name_development
  username: your_username
  password: your_password
```

### Step 3: Run Setup

The `bin/setup` script handles:
- Installing Ruby gems (`bundle install`)
- Installing JavaScript packages (`yarn install`)
- Creating necessary directories
- Setting up encryption keys (creates `credentials.yml.enc` and `master.key`)
- Creating database
- Running migrations
- Building assets

```bash
bin/setup
```

### Step 4: Start Development Server

```bash
bin/dev
```

Visit http://localhost:3000

### Manual Setup (Alternative)

If you prefer to set up manually or the automated script doesn't work:

```bash
# 1. Install dependencies
bundle install
yarn install

# 2. Create directories (if not already created)
mkdir -p app/assets/config app/assets/images app/assets/builds
touch app/assets/builds/.keep

# 3. Create manifest.js (if not copied)
cat > app/assets/config/manifest.js << 'EOF'
//= link_tree ../images
//= link_directory ../builds .css
//= link application.js
EOF

# 4. Set encryption key (development will auto-generate, but set for production)
rails credentials:edit
# Add: lockbox_master_key: <generate-with-openssl-rand-hex-32>

# 5. Configure database (edit config/database.yml) then create it
rails db:create
rails db:migrate

# 6. Build CSS
yarn build:css

# 7. Start server
bin/dev
```

## Features

- **Rails 7.1** with React 18 integration
- **HIPAA Compliance** - Encryption, audit logging, MFA support
- **Authentication** - Devise with two-factor authentication support
- **Code Quality** - Rubocop, Prettier, ESLint
- **Background Jobs** - Sidekiq for async processing
- **Security** - Secure headers, rate limiting, input validation
- **TailwindCSS** - Simplified theme (customize as needed)

## Prerequisites

- Ruby 3.3.0
- PostgreSQL
- Redis
- Node.js 18+ and Yarn

**Note:** The `bin/setup` script handles most of the setup automatically. See the [Quick Start](#-quick-start) section above for the simplest setup process.

## HIPAA Compliance Checklist

### ✅ Enabled by Default (User Model)

The User model has the following HIPAA features **already enabled**:
- ✅ Field-level encryption (`encrypts` on common PHI fields)
- ✅ Audit logging (`has_paper_trail`)
- ✅ MFA infrastructure (devise-two-factor with TOTP support)
- ✅ Secure headers (CSP, HSTS, etc.)
- ✅ Rate limiting (Rack::Attack)

**Note:** Customize the encrypted fields in `app/models/user.rb` based on your PHI requirements.

### Critical Requirements (Day 1)

- [x] Encryption infrastructure configured (Lockbox)
- [x] Audit logging infrastructure configured (Paper Trail)
- [x] MFA infrastructure configured (devise-two-factor)
- [x] Secure headers configured
- [x] Rate limiting configured
- [x] MFA setup controller created (`Users::TwoFactorSetupController`)
- [x] Audit log controller created (`Admin::AuditsController`)
- [x] Production environment security configured
- [x] Example PHI model template provided
- [x] React MFA setup component (`TwoFactorSetup.jsx`)
- [x] Audit log views (index, show, phi_access)
- [x] Pundit authorization policies (ApplicationPolicy, AuditPolicy)
- [x] API utility for authenticated requests
- [ ] Set `LOCKBOX_MASTER_KEY` in production credentials (not dev temp key)
- [ ] Add `encrypts` and `has_paper_trail` to **other PHI models** (see `example_phi_model.rb`)
- [ ] Customize admin role check in `AuditPolicy` (currently checks `user.admin?` or `user.has_role?(:admin)`)
- [ ] Customize PHI fields in User model if needed
- [ ] Sign Business Associate Agreements (BAAs) with all vendors
- [ ] Create HIPAA Privacy Policy (template in `policies/` directory)
- [ ] Create HIPAA Security Policy (template in `policies/` directory)
- [ ] Create Incident Response Plan (template in `policies/` directory)

### High Priority

- [x] Secure headers configured (already set up in initializer)
- [ ] Set up centralized logging (CloudWatch/ELK)
- [ ] Implement data retention policies
- [ ] Set up backup and disaster recovery
- [ ] Configure security scanning in CI/CD (Brakeman, bundler-audit)
- [ ] Review and customize policy templates in `policies/` directory

## Project Structure

```
app/
  javascript/          # React components and application code
    - components/     # React components
      - TwoFactorSetup.jsx # MFA setup UI
    - utils/          # Utilities
      - api.js        # API client with CSRF token handling
  views/              # ERB templates
    - admin/audits/   # Audit log views (index, show, phi_access)
  models/             # ActiveRecord models
    - user.rb         # HIPAA features enabled (encryption, audit, MFA)
    - example_phi_model.rb # Example template for other PHI models
  controllers/        # Rails controllers
    - users/two_factor_setup_controller.rb # MFA setup (HTML + JSON)
    - admin/audits_controller.rb # Audit log viewing (with Pundit)
  policies/           # Pundit authorization policies
    - application_policy.rb # Base policy class
    - audit_policy.rb # Audit log access control
  services/           # Business logic services
    - data_retention_policy.rb # Data retention automation
config/
  initializers/       # Configuration files
  environments/       # Environment configs
    - production.rb   # Production security settings
  - lockbox.rb        # Encryption configuration
  - secure_headers.rb # Security headers
  - paper_trail.rb    # Audit logging
  - sidekiq.rb        # Background jobs
  - devise.rb         # Authentication with MFA support
policies/             # HIPAA policy templates (customize for your organization)
db/migrate/           # Database migrations (includes User model with MFA fields)
```

## Key Gems

### Core
- `rails ~> 7.1.3` - Web framework
- `react-rails` - React integration
- `devise ~> 4.9` - Authentication

### HIPAA Compliance
- `lockbox` - Field-level encryption
- `paper_trail` - Audit logging
- `devise-two-factor` - Multi-factor authentication
- `secure_headers` - Security headers

### Background Jobs
- `sidekiq` - Background job processing
- `whenever` - Scheduled tasks

### Security
- `rack-attack` - Rate limiting
- `brakeman` - Static security analysis
- `bundler-audit` - Dependency vulnerability scanning

## Development Tools

- **Rubocop** - Ruby code linting
- **Prettier** - JavaScript/CSS formatting
- **ESLint** - JavaScript linting
- **Husky** - Git hooks
- **Letter Opener Web** - Email preview in development

## Available Routes

### MFA Setup (HIPAA Compliance)
- `GET /users/two_factor_setup/new` - Show QR code for MFA setup
- `POST /users/two_factor_setup` - Enable MFA after verification
- `DELETE /users/two_factor_setup` - Disable MFA
- `GET /users/two_factor_setup/backup_codes` - View backup codes

### Audit Logs (Admin Only - HIPAA Compliance)
- `GET /admin/audits` - List all audit logs
- `GET /admin/audits/:id` - View specific audit log entry
- `GET /admin/audits/phi_access` - View PHI access logs

**Note:** Authorization is already configured with Pundit. Customize `AuditPolicy` to match your admin role system.

## Configuration

See [CONFIGURATION.md](./CONFIGURATION.md) for detailed configuration options including:
- Environment variables
- Customizing application name and branding
- Seed data configuration
- PHI field customization
- Production deployment checklist

## Resources

- [Configuration Guide](./CONFIGURATION.md) - How to customize the starter for your needs
- [HIPAA Compliance Plan](./HIPAA_COMPLIANCE_PLAN.md) - Comprehensive compliance guide
- [Lockbox Documentation](https://github.com/ankane/lockbox)
- [Paper Trail Documentation](https://github.com/paper-trail-gem/paper_trail)
- [Devise Two-Factor](https://github.com/tinybike/devise-two-factor)

## License

[Your License Here]

