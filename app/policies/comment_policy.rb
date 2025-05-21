class CommentPolicy < ApplicationPolicy
 
  def index?
    true
  end

  def create?
    user.present?
  end

  # Может только создатель блога и админ
  def update?
    Rails.logger.info "Checking update permissions: user=#{user&.id}, record.user=#{record.user.id}, admin=#{user&.admin?}"
    user.present? && (record.user_id == user.id || user.admin?)
  end

   # Удалять может создатель или админ
  def destroy?
    user.present? && (record.user_id == user.id || user.admin?)
  end

  def can_modify?
    user.present? && (record.user == user || user.admin?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
