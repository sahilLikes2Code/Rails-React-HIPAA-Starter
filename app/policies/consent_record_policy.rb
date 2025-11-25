# frozen_string_literal: true

class ConsentRecordPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    owns_record? || admin_user?
  end

  class Scope < Scope
    def resolve
      if admin_user?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end

    private

    def admin_user?
      user&.respond_to?(:admin?) && user.admin? || user&.respond_to?(:has_role?) && user.has_role?(:admin)
    end
  end

  private

  def owns_record?
    record.user_id == user.id
  end

  def admin_user?
    user&.respond_to?(:admin?) && user.admin? || user&.respond_to?(:has_role?) && user.has_role?(:admin)
  end
end

