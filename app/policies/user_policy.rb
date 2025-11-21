# frozen_string_literal: true

# Pundit policy for User model - prevents unauthorized PHI access (HIPAA Compliance)
class UserPolicy < ApplicationPolicy
  def show?
    user.present? && (record.id == user.id || user.has_role?(:admin))
  end

  def update?
    show?
  end

  def edit?
    update?
  end

  def create?
    # Allow registration for new users. To restrict, change to: user&.has_role?(:admin)
    true
  end

  def destroy?
    user&.has_role?(:admin)
  end

  class Scope < Scope
    def resolve
      if user&.has_role?(:admin)
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end

