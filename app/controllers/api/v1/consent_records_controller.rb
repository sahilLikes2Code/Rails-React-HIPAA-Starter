# frozen_string_literal: true

module Api
  module V1
    class ConsentRecordsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_consent_record, only: :update

      def index
        consent_records = policy_scope(ConsentRecord).order(:purpose)
        render json: consent_records
      end

      def create
        consent_record = ConsentRecord.find_or_initialize_by(user: current_user, purpose: consent_params[:purpose])
        consent_record.assign_attributes(consent_attributes)
        authorize consent_record

        if consent_record.save
          render json: consent_record, status: :created
        else
          render json: { errors: consent_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @consent_record

        if @consent_record.update(consent_attributes)
          render json: @consent_record
        else
          render json: { errors: @consent_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def consent_params
        params.require(:consent_record).permit(:purpose, :granted, :source, :jurisdiction, metadata: {})
      end

      def consent_attributes
        consent_params.merge(
          data_subject_identifier: current_user&.email,
          user: current_user,
          source: consent_params[:source].presence || "self_service"
        )
      end

      def set_consent_record
        @consent_record = policy_scope(ConsentRecord).find(params[:id])
      end
    end
  end
end

