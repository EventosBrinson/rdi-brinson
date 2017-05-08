class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin? || user.staff?
      can :manage, User
      cannot :update, User do |subject|
        ((subject.admin? || subject.staff?) and subject.id != user.id) or subject.role_changed?
      end
    end

    if user.user?
      can :read, User do |subject|
        subject.id == user.id
      end

      can :update, User do |subject|
        subject.id == user.id and !subject.role_changed?
      end
    end
  end
end
