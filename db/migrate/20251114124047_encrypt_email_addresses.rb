# frozen_string_literal: true

class EncryptEmailAddresses < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :email_ciphertext, :text

    User.reset_column_information
    User.find_each do |user|
      plaintext_email = user.read_attribute(:email)
      if plaintext_email.present?
        user.email = plaintext_email
        user.save(validate: false)
      end
    end
  end

  def down
    User.reset_column_information
    User.find_each do |user|
      if user.email_ciphertext.present?
        decrypted_email = user.email
        user.update_column(:email, decrypted_email) if decrypted_email.present?
      end
    end

    remove_column :users, :email_ciphertext
  end
end
