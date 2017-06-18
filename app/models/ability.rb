class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if high_level_user?(user)
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
    can :show, User
    can :index, User
    can :update, User do |subject|
      user.main or (!high_level_user?(subject) and !to_high_level_user?(subject)) or (user == subject and !subject.role_changed? and !subject.active_changed?)
    end
    can :create, User do |subject|
      user.main or !high_level_user?(subject)
    end
  end

  def user_on_users(user)
    can :show, User do |subject|
      subject.id == user.id
    end
    can :update, User do |subject|
      subject.id == user.id and !subject.role_changed? and !subject.active_changed?
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
      user_owns_rent(user, subject) and (rent_only_status_changed(subject) or rent_on_pick_up_changed_additional_charges(subject) or subject.status == 'reserved')
    end
  end

  def user_owns_rent(user, rent)
    rent.creator_id == user.id and rent.client.creator_id == user.id and rent.place.client.creator_id == user.id
  end

  def rent_only_status_changed(rent)
    fields_changed = rent.changed_attributes.keys
    fields_changed.size == 0 or (fields_changed.size == 1 and fields_changed.first == 'status')
  end

  def rent_on_pick_up_changed_additional_charges(rent)
    fields_changed = rent.changed_attributes.keys
    unpermited_fileds = fields_changed.select { |attribute| attribute != 'additional_charges' and attribute != 'additional_charges_notes' }
    unpermited_fileds.empty? and rent.status == 'on_pick_up'
  end
end
