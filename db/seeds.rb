# frozen_string_literal: true

# This file seeds the database with initial data for development and testing.
# Configure seed data via environment variables (see .env.example)
#
# To customize seed data, set these environment variables:
#   SEED_ADMIN_EMAIL, SEED_ADMIN_PASSWORD, SEED_ADMIN_FIRST_NAME, SEED_ADMIN_LAST_NAME

puts "🌱 Seeding database..."

# Configuration from environment variables (with sensible defaults for development)
admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("SEED_ADMIN_PASSWORD", "password123")
admin_first_name = ENV.fetch("SEED_ADMIN_FIRST_NAME", "Admin")
admin_last_name = ENV.fetch("SEED_ADMIN_LAST_NAME", "User")

# Clear existing data (optional - comment out if you want to keep existing data)
puts "  Clearing existing data..."
User.destroy_all
Role.destroy_all if defined?(Role)

# Create admin role
puts "  Creating roles..."
admin_role = Role.find_or_create_by!(name: "admin")

# Create regular user role (for future use)
user_role = Role.find_or_create_by!(name: "user")

# Create admin user
puts "  Creating admin user..."
admin_user = User.create!(
  email: admin_email,
  password: admin_password,
  password_confirmation: admin_password,
  first_name: admin_first_name,
  last_name: admin_last_name,
  phone_number: "+1-555-0100",
  date_of_birth: Date.new(1980, 1, 1)
)
admin_user.add_role(:admin)
puts "    ✅ Created admin user: #{admin_user.email}"

# Create regular users
puts "  Creating regular users..."
regular_users = [
  {
    email: "john.doe@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "John",
    last_name: "Doe",
    phone_number: "+1-555-0101",
    date_of_birth: Date.new(1990, 5, 15)
  },
  {
    email: "jane.smith@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Jane",
    last_name: "Smith",
    phone_number: "+1-555-0102",
    date_of_birth: Date.new(1985, 8, 20)
  },
  {
    email: "bob.johnson@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Bob",
    last_name: "Johnson",
    phone_number: "+1-555-0103",
    date_of_birth: Date.new(1992, 3, 10)
  }
]

regular_users.each do |user_attrs|
  user = User.create!(user_attrs)
  user.add_role(:user)
  puts "    ✅ Created user: #{user.email}"
end

# Generate some audit log entries by making changes to users
puts "  Generating audit log entries..."
PaperTrail.request(enabled: true) do
  # Update admin user to create an audit log
  # Find fresh from DB and update with validate: false since we know the data is valid
  admin = User.find_by(email: admin_email)
  admin.first_name = "Administrator"
  admin.save(validate: false)
  puts "    ✅ Created audit log for admin user update"

  # Update regular users to create more audit logs
  User.where.not(email: admin_email).limit(2).each do |user|
    user.phone_number = "+1-555-#{rand(1000..9999)}"
    user.save(validate: false)
    puts "    ✅ Created audit log for user: #{user.email}"
  end

  # Create a new user to generate a 'create' audit log
  new_user = User.create!(
    email: "new.user@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "New",
    last_name: "User",
    phone_number: "+1-555-0104",
    date_of_birth: Date.new(1995, 12, 25)
  )
  new_user.add_role(:user)
  puts "    ✅ Created user with audit log: #{new_user.email}"
end

puts ""
puts "✅ Seeding complete!"
puts ""
puts "📋 Summary:"
puts "  - Admin user: #{admin_email} (password: #{admin_password})"
puts "  - Regular users: #{User.count - 1} users created"
puts "  - Roles: admin, user"
puts "  - Audit logs: #{PaperTrail::Version.count} entries"
puts ""
puts "🔐 Login Credentials:"
puts "  Admin: #{admin_email} / #{admin_password}"
puts "  User: john.doe@example.com / password123"
puts ""
puts "💡 Tip: Customize seed data by setting SEED_ADMIN_EMAIL, SEED_ADMIN_PASSWORD, etc. in .env"
puts ""

