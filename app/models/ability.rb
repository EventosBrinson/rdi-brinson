class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin? || user.staff?
      admin_on_users(user)
      can :manage, Client
      can :manage, Document
      can :manage, Place
      can :manage, Rent
    end

    if user.user?
      user_on_users(user)
      user_on_clients(user)
      user_on_documents(user)
      user_on_places(user)
      user_on_rents(user)
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

  def admin_on_users(user)
    can :manage, User
    cannot :update, User do |subject|
      ((subject.id == user.id and subject.role_changed?) or (high_level_user?(subject) and subject.id != user.id) or to_high_level_user?(subject)) and !user.main
    end
    cannot :create, User do |subject|
      high_level_user?(subject) and !user.main
    end
  end

  def user_on_users(user)
    can :show, User do |subject|
      subject.id == user.id
    end
    can :update, User do |subject|
      subject.id == user.id and !subject.role_changed?
    end
  end

  def user_on_clients(user)
    can :index, Client
    can :create, Client
    can [:show, :update], Client do |subject|
      subject.creator_id == user.id and !subject.active_changed?
    end
  end

  def user_on_documents(user)
    can [:show, :create, :update, :delete], Document do |subject|
      subject.client.creator_id == user.id
    end
  end

  def user_on_places(user)
    can :index, Place
    can [:show, :create], Place do |subject|
      subject.client.creator_id == user.id
    end
    can :update, Place do |subject|
      subject.client.creator_id == user.id and !subject.active_changed?
    end
  end

  def user_on_rents(user)
    can :index, Rent
    can [:show, :create], Rent do |subject|
      user_owns_rent(user, subject)
    end
    can :update, Rent do |subject|
      fileds_changed = subject.changed_attributes.keys
      user_owns_rent(user, subject) and (fileds_changed.size == 0 or (fileds_changed.size == 1 and fileds_changed.first == 'status') or subject.status == 'reserved')
    end
  end

  def user_owns_rent(user, rent)
    rent.creator_id == user.id and rent.client.creator_id == user.id and rent.place.client.creator_id == user.id
  end
end
