# Configuration Guide

This guide explains how to configure the application for your specific use case.

## Environment Variables

Create a `.env` file in the root directory (or use your preferred environment variable management). Here are the key variables:

### Required for Production

```bash
# Encryption Keys (REQUIRED - generate with: openssl rand -hex 32)
LOCKBOX_MASTER_KEY="your_lockbox_master_key_here"

# Rails Secret Key Base (auto-generated in development)
SECRET_KEY_BASE="your_secret_key_base_here"

# Application URL
APP_URL="https://yourdomain.com"
MAILER_HOST="yourdomain.com"
MAILER_SENDER="noreply@yourdomain.com"

# CORS Configuration (comma-separated list)
ALLOWED_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"
```

### Optional Configuration

```bash
# Seed Data (for development/testing)
SEED_ADMIN_EMAIL="admin@yourdomain.com"
SEED_ADMIN_PASSWORD="your_secure_password"
SEED_ADMIN_FIRST_NAME="Admin"
SEED_ADMIN_LAST_NAME="User"

# Database
DATABASE_URL="postgresql://username:password@localhost:5432/your_app_development"

# Redis (for Sidekiq)
REDIS_URL="redis://localhost:6379/0"
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
- [ ] Set up monitoring and logging
- [ ] Review rate limiting in `config/initializers/rack_attack.rb`

## Security Notes

- **Never commit** `.env` files or `master.key` to version control
- **Rotate encryption keys** periodically
- **Use strong passwords** for seed data (even in development)
- **Review audit logs** regularly
- **Keep dependencies updated** (`bundle update`, `yarn upgrade`)

