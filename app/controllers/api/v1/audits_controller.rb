# frozen_string_literal: true

module Api
  module V1
    # Controller for viewing audit logs (HIPAA Compliance)
    # JSON-only API endpoint for audit log viewing
    class AuditsController < BaseController
      # GET /api/v1/audits
      def index
        authorize PaperTrail::Version

        versions = policy_scope(PaperTrail::Version)
          .order(created_at: :desc)

        # Filter by model type if provided
        versions = versions.where(item_type: params[:item_type]) if params[:item_type].present?

        # Filter by user if provided
        versions = versions.where(whodunnit: params[:user_id]) if params[:user_id].present?

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 50
        versions = versions.paginate(page: page, per_page: per_page)

        render_success({
          audits: versions.map { |v| serialize_version(v) },
          pagination: {
            current_page: versions.current_page,
            per_page: versions.per_page,
            total_pages: versions.total_pages,
            total_entries: versions.total_entries
          }
        })
      end

      # GET /api/v1/audits/:id
      def show
        version = PaperTrail::Version.find(params[:id])
        authorize version

        render_success({
          audit: serialize_version(version, include_details: true)
        })
      end

      # GET /api/v1/audits/phi_access
      def phi_access
        authorize PaperTrail::Version, :phi_access?

        # Filter for versions that contain PHI field changes
        phi_fields = %w[first_name last_name phone_number date_of_birth email]

        versions = policy_scope(PaperTrail::Version)
          .where("object_changes LIKE ? OR object LIKE ?",
                 "%#{phi_fields.join('%')}%",
                 "%#{phi_fields.join('%')}%")
          .order(created_at: :desc)

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 50
        versions = versions.paginate(page: page, per_page: per_page)

        render_success({
          audits: versions.map { |v| serialize_version(v) },
          pagination: {
            current_page: versions.current_page,
            per_page: versions.per_page,
            total_pages: versions.total_pages,
            total_entries: versions.total_entries
          }
        })
      end

      private

      def serialize_version(version, include_details: false)
        user = version.whodunnit.present? ? User.find_by(id: version.whodunnit) : nil

        data = {
          id: version.id,
          event: version.event,
          item_type: version.item_type,
          item_id: version.item_id,
          whodunnit: version.whodunnit,
          user_email: user&.email || "System",
          created_at: version.created_at.iso8601
        }

        if include_details
          phi_fields = %w[first_name last_name phone_number date_of_birth email]
          
          object = version.object&.dup || {}
          object_changes = version.object_changes&.dup || {}
          
          if object.is_a?(Hash)
            phi_fields.each do |field|
              if object[field]
                object[field] = "[REDACTED]"
              end
              if object[field.to_s]
                object[field.to_s] = "[REDACTED]"
              end
            end
          end
          
          if object_changes.is_a?(Hash)
            phi_fields.each do |field|
              if object_changes[field]
                object_changes[field] = ["[REDACTED]", "[REDACTED]"]
              end
              if object_changes[field.to_s]
                object_changes[field.to_s] = ["[REDACTED]", "[REDACTED]"]
              end
            end
          end
          
          data[:object] = object
          data[:object_changes] = object_changes
          data[:item] = version.item ? {
            id: version.item.id,
            class: version.item.class.name
          } : nil
        end

        data
      end
    end
  end
end

