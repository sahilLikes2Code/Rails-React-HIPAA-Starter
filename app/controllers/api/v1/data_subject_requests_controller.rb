# frozen_string_literal: true

module Api
  module V1
    class DataSubjectRequestsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_request, only: :update

      def index
        requests = policy_scope(DataSubjectRequest).order(created_at: :desc)
        render json: requests
      end

      def create
        request = current_user.data_subject_requests.build(request_params.merge(data_subject_identifier: current_user.email))
        authorize request

        if request.save
          ProcessDataSubjectRequestJob.perform_later(request.id)
          render json: request, status: :created
        else
          render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @data_subject_request

        if @data_subject_request.update(admin_update_params)
          render json: @data_subject_request
        else
          render json: { errors: @data_subject_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_request
        @data_subject_request = policy_scope(DataSubjectRequest).find(params[:id])
      end

      def request_params
        params.require(:data_subject_request).permit(:request_type, :notes, metadata: {})
      end

      def admin_update_params
        params.require(:data_subject_request).permit(:status, :notes)
      end
    end
  end
end

