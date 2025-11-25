class CreateDataSubjectRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :data_subject_requests do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :data_subject_identifier, null: false
      t.string :request_type, null: false
      t.string :status, null: false, default: "queued"
      t.datetime :due_at
      t.datetime :completed_at
      t.jsonb :metadata, default: {}
      t.text :notes

      t.timestamps
    end

    add_index :data_subject_requests, :request_type
    add_index :data_subject_requests, :status
    add_index :data_subject_requests, [:data_subject_identifier, :request_type], name: "index_dsr_on_identifier_and_type"
  end
end

