# frozen_string_literal: true

class RemoveNotNullFromPhiFields < ActiveRecord::Migration[7.1]
  def change
    # Remove NOT NULL constraints from PHI ciphertext columns
    # Application-level validations enforce required fields
    # Lockbox encrypts during save, and blank values might not encrypt properly
    change_column_null :users, :first_name_ciphertext, true
    change_column_null :users, :last_name_ciphertext, true
    change_column_null :users, :phone_number_ciphertext, true
    change_column_null :users, :date_of_birth_ciphertext, true
  end
end

