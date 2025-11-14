# frozen_string_literal: true

# Pundit policy for PaperTrail::Version (audit logs)
# This policy is namespaced to match PaperTrail::Version
module PaperTrail
  class VersionPolicy < ApplicationPolicy
    # Only admins can view audit logs
    def index?
      user.present? && user.has_role?(:admin)
    end

    def show?
      index?
    end

    def phi_access?
      index?
    end

    class Scope < Scope
      def resolve
        # Only admins can see audit logs
        if user.present? && user.has_role?(:admin)
          scope.all
        else
          scope.none
        end
      end
    end
  end
end

