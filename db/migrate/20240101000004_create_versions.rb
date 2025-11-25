# frozen_string_literal: true

# Paper Trail versions table for audit logging (HIPAA Compliance)
# This table stores all changes to models that have has_paper_trail
class CreateVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :versions, id: :uuid do |t|
      t.string :item_type, null: false
      t.uuid :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.text :object
      t.text :object_changes
      t.datetime :created_at
    end

    add_index :versions, [:item_type, :item_id]
    add_index :versions, :whodunnit
    add_index :versions, :created_at
  end
end

