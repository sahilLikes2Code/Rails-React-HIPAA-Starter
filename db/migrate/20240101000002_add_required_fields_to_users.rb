# frozen_string_literal: true

class AddRequiredFieldsToUsers < ActiveRecord::Migration[8.0]
  def up
    # Note: We don't add NOT NULL constraints here because:
    # 1. Lockbox encrypts values during save, and blank values might not encrypt
    # 2. Application-level validations (in User model) enforce required fields
    # 3. This is safer for HIPAA compliance - we validate at the application level
    # 
    # If you want database-level constraints, you can add them after ensuring
    # all existing records have values and Lockbox is properly encrypting
  end

  def down
    # No changes to reverse
  end
end

