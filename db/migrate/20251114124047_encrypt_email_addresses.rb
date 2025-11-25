# frozen_string_literal: true

class EncryptEmailAddresses < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :email_ciphertext, :text
  end

  def down
    remove_column :users, :email_ciphertext
  end
end
