class CreateConsentRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :consent_records do |t|
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.string :data_subject_identifier, null: false
      t.string :purpose, null: false
      t.boolean :granted, default: true, null: false
      t.datetime :granted_at
      t.datetime :revoked_at
      t.string :source
      t.string :jurisdiction, default: "US"
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :consent_records, [:data_subject_identifier, :purpose], unique: true, name: "index_consent_records_on_subject_and_purpose"
  end
end

