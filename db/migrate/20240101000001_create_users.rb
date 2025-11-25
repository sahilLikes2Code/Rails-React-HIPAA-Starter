# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      # Devise fields
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      
      # Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      
      # Rememberable
      t.datetime :remember_created_at
      
      # Trackable (optional - uncomment if needed)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip
      
      # Confirmable (optional - uncomment if needed)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email
      
      # Lockable (optional - uncomment if needed)
      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at
      
      # Two-Factor Authentication fields (HIPAA Compliance)
      t.string :otp_secret
      t.boolean :otp_required_for_login, default: false
      t.text :otp_backup_codes, array: true, default: []
      
      # PHI fields (encrypted with Lockbox)
      # Lockbox stores encrypted data in _ciphertext columns
      # Customize these based on your application's PHI requirements
      # NOTE: Email is stored unencrypted (needed for Devise authentication)
      t.text :first_name_ciphertext   # Encrypted by Lockbox
      t.text :last_name_ciphertext    # Encrypted by Lockbox
      t.text :phone_number_ciphertext # Encrypted by Lockbox
      t.text :date_of_birth_ciphertext # Encrypted by Lockbox
      
      # Optional: Blind indexes for encrypted field searching
      # Uncomment and add to User model if you need to search these encrypted fields
      # t.string :first_name_bidx
      # t.string :last_name_bidx
      # t.string :phone_number_bidx
      
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    # Uncomment if using blind indexes for encrypted field searching
    # add_index :users, :email_bidx
    # add_index :users, :first_name_bidx
    # add_index :users, :last_name_bidx
    # add_index :users, :phone_number_bidx
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end
end

