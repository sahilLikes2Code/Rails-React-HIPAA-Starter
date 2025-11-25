# Configuration Guide

This guide explains how to configure the application for your specific use case.

## Environment Variables

Create a `.env` file (or populate your secrets manager). The table below summarizes the most important variables.

| Variable | Required? | Default / Example | Purpose |
| --- | --- | --- | --- |
| `LOCKBOX_MASTER_KEY` | ✅ Production | `openssl rand -hex 32` | Encrypts PHI fields via Lockbox |
| `SECRET_KEY_BASE` | ✅ Production | auto-set in dev; `rails secret` | Rails session + encryption |
| `APP_URL` | ✅ | `https://app.example.com` | Used in mailers/links |
| `MAILER_HOST` / `MAILER_SENDER` | ✅ | `app.example.com` / `noreply@example.com` | Devise emails |
| `ALLOWED_ORIGINS` | ✅ | `https://app.example.com` | CORS whitelist |
| `DATABASE_URL` | ⚙️ | `postgres://user:pass@host/db` | Heroku/production DB |
| `REDIS_URL` | ⚙️ | `redis://localhost:6379/0` | Sidekiq/rate limiting |
| `SEED_ADMIN_*` | Dev convenience | `admin@example.com`, etc. | Controls seed data |
| `DATA_RETENTION_OVERRIDES` | Optional | `{"SecurityEvent":730}` | Adjust retention windows (days) |
| `MONITORING_WEBHOOK_URL` | Optional | `https://hooks.slack.com/...` | Sends compliance alerts to chat/on-call |

Example `.env` snippet:

```bash
LOCKBOX_MASTER_KEY=$(openssl rand -hex 32)
SECRET_KEY_BASE=$(rails secret)
APP_URL="https://app.example.com"
MAILER_HOST="app.example.com"
MAILER_SENDER="noreply@app.example.com"
ALLOWED_ORIGINS="https://app.example.com,https://admin.app.example.com"

DATABASE_URL="postgresql://postgres@localhost:5432/hipaa_dev"
REDIS_URL="redis://localhost:6379/0"

SEED_ADMIN_EMAIL="admin@app.example.com"
SEED_ADMIN_PASSWORD="SuperSecure123!"

DATA_RETENTION_OVERRIDES='{"SecurityEvent":730,"ConsentRecord":365}'
MONITORING_WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"
```

## Customizing the Application

### 1. Application Name

The application name appears in the navigation and homepage. To customize:

Edit `app/javascript/App.jsx` and change the `APP_NAME` constant at the top of the file:

```javascript
// Application name - customize this for your application
const APP_NAME = "Your App Name";
```

This is the simplest approach for a starter template - just change one line of code.

### 2. Seed Data

Customize the seed data by setting environment variables before running `rails db:seed`:

```bash
SEED_ADMIN_EMAIL="admin@yourdomain.com"
SEED_ADMIN_PASSWORD="your_secure_password"
SEED_ADMIN_FIRST_NAME="Admin"
SEED_ADMIN_LAST_NAME="User"
rails db:seed
```

### 3. Email Configuration

Update `config/initializers/devise.rb` or set the `MAILER_SENDER` environment variable:

```bash
MAILER_SENDER="noreply@yourdomain.com"
```

### 4. PHI Fields

Customize which fields are encrypted in `app/models/user.rb`:

```ruby
# Add or remove fields based on your PHI requirements
encrypts :first_name, :last_name, :phone_number, :date_of_birth, :ssn
```

### 5. Roles

The starter includes `admin` and `user` roles. Add more roles in `db/seeds.rb` or via the Rails console:

```ruby
Role.find_or_create_by!(name: "your_role_name")
user.add_role(:your_role_name)
```

### 6. Branding and Styling

- **Colors**: Edit Tailwind configuration in `tailwind.config.js`
- **Logo**: Replace the SVG icons in `app/javascript/App.jsx` with your logo
- **Favicon**: Replace `app/assets/images/favicon.ico`

### 7. Monitoring & Alerting

- Set `MONITORING_WEBHOOK_URL` to forward compliance/incident events to Slack, PagerDuty, Opsgenie, etc.
- Test delivery:
  ```bash
  rails runner 'Compliance::AuditLogger.log(event_type: "monitoring.test", actor: "ops", resource: "webhook", metadata: {})'
  tail -f log/compliance.log
  ```
- Review `policies/MONITORING_AND_ALERTING_GUIDE.md` for routing examples.

### 8. Consent & Privacy UI

- `/privacy/consent` renders the React consent center backed by `ConsentRecord`.
- Define the set of consent purposes in `app/javascript/components/ConsentManager.jsx`.

### 9. Data Subject Requests

- Users submit GDPR requests at `/privacy/requests`.
- Configure background processing (Sidekiq/GoodJob/etc.) so `ProcessDataSubjectRequestJob` runs automatically.
- Customize the fulfillment logic inside `app/jobs/process_data_subject_request_job.rb`.
- Manually trigger a job to verify logging/output:
  ```bash
  rails runner 'ProcessDataSubjectRequestJob.perform_now(DataSubjectRequest.first.id)'
  ```

## Production Checklist

Before deploying to production:

- [ ] Set `LOCKBOX_MASTER_KEY` (generate with `openssl rand -hex 32`)
- [ ] Set `SECRET_KEY_BASE` (Rails generates this automatically)
- [ ] Update `MAILER_HOST` and `MAILER_SENDER`
- [ ] Configure `ALLOWED_ORIGINS` for CORS
- [ ] Review and customize PHI fields in User model
- [ ] Set up proper database backups
- [ ] Configure SSL/TLS certificates
- [ ] Review security headers in `config/initializers/secure_headers.rb`
- [ ] Set up monitoring and logging (see `MONITORING_WEBHOOK_URL`)
- [ ] Review rate limiting in `config/initializers/rack_attack.rb`
- [ ] Schedule `DataRetentionPolicy.purge_expired` (cron/Whenever) and monitor `log/compliance.log`
- [ ] Run periodic exports of consent + data subject requests for audit evidence
- [ ] Run `rails runner 'Compliance::AuditLogger.log(event_type: "compliance.healthcheck", actor: "ops", resource: "checklist", metadata: {})'` and store the resulting log entry as evidence

## Security Notes

- **Never commit** `.env` files or `master.key` to version control
- **Rotate encryption keys** periodically
- **Use strong passwords** for seed data (even in development)
- **Review audit logs** regularly
- **Keep dependencies updated** (`bundle update`, `yarn upgrade`)

