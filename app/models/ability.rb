class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin? || user.staff?
      can :manage, User
      cannot :update, User do |subject|
        ((subject.id == user.id and subject.role_changed?) or (high_level_user?(subject) and subject.id != user.id) or to_high_level_user?(subject)) and !user.main
      end
      cannot :create, User do |subject|
        high_level_user?(subject) and !user.main
      end
      can :manage, Client
      can :manage, Document
    end

    if user.user?
      can :read, User do |subject|
        subject.id == user.id
      end

      can :update, User do |subject|
        subject.id == user.id and !subject.role_changed?
      end

      cannot :index, User
      cannot :show, User

      can :index, Client
      can :create, Client
      can :update, Client do |subject|
        subject.creator_id == user.id and !subject.active_changed?
      end

      can :show, Document
      can [:create, :update, :delete], Document do |subject|
        subject.client.creator_id == user.id
      end
    end
  end

  private

  def high_level_user?(user)
    if user.role_changed? and !user.new_record?
      user.role_was == 'admin' || user.role_was == 'staff'
    else
      user.admin? || user.staff?
    end
  end

  def to_high_level_user?(user)
    if user.role_changed?
      user.admin? || user.staff?
    end
  end
end
