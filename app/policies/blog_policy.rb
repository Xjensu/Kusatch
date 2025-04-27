class BlogPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  # Может только создатель блога и админ
  def update?
    user.present? && (record.user == user || user.admin?)
  end

   # Удалять может создатель или админ
  def destroy?
    user.present? && (record.user == user || user.admin?)
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
