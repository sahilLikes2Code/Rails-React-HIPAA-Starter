# frozen_string_literal: true

# Example PHI Model - Medical Record
# This demonstrates how to add HIPAA compliance to other models containing PHI
# Copy this pattern to your actual PHI models

# class MedicalRecord < ApplicationRecord
#   # HIPAA Compliance: Encrypt all PHI fields using Lockbox
#   # Rails encryption is disabled in config/application.rb, so encrypts uses Lockbox
#   extend Lockbox::Model
#   encrypts :diagnosis, :treatment_notes, :medication_list, :allergies,
#            :lab_results, :imaging_notes, :medical_record_number
#
#   # HIPAA Compliance: Audit logging for all changes
#   has_paper_trail
#
#   # Associations
#   belongs_to :user
#
#   # Validations
#   validates :medical_record_number, presence: true, uniqueness: true
#
#   # Scopes
#   scope :recent, -> { order(created_at: :desc) }
# end

# Migration example:
# class CreateMedicalRecords < ActiveRecord::Migration[8.0]
#   def change
#     create_table :medical_records, id: :uuid do |t|
#       t.references :user, null: false, foreign_key: true, type: :uuid
#       t.text :diagnosis_ciphertext
#       t.text :treatment_notes_ciphertext
#       t.text :medication_list_ciphertext
#       t.text :allergies_ciphertext
#       t.text :lab_results_ciphertext
#       t.text :imaging_notes_ciphertext
#       t.text :medical_record_number_ciphertext
#       t.timestamps
#     end
#   end
# end

