# frozen_string_literal: true

# Pundit policy for audit logs (HIPAA Compliance)
# Only admins should be able to view audit logs
# 
# NOTE: Customize the admin check based on your authorization system:
# - If using a simple `admin` boolean: `user&.admin?`
# - If using Rolify: `user&.has_role?(:admin)`
# - If using CanCanCan: `user&.has_role?(:admin)`
# - Add your own role checking logic here
class AuditPolicy < ApplicationPolicy
  # Only admins can view audit logs
  def index?
    # Using Rolify for role-based access control
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

