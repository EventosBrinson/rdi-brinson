class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin? || user.staff?
      can :manage, User
      cannot :update, User do |subject|
        ((subject.id == user.id and subject.role_changed?) or (high_level_user?(subject) and subject.id != user.id)) and !user.main
      end
      cannot :create, User do |subject|
        high_level_user?(subject) and !user.main
      end
    end

    if user.user?
      can :read, User do |subject|
        subject.id == user.id
      end

      can :update, User do |subject|
        subject.id == user.id and !subject.role_changed?
      end

      cannot :index, User
    end
  end

  private

  def high_level_user?(user)
    if user.role_changed? and !user.new_record?
      user.role_was == :admin || user.role_was == :staff
    else
      user.admin? || user.staff?
    end
  end
end
