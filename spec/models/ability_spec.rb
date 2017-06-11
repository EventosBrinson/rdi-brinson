require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:staff) { FactoryGirl.create(:user, :staff) }
  let(:main) { FactoryGirl.create(:user, :admin, :main) }
  let(:average_user) { FactoryGirl.create(:user) }

  let(:user_role_changed) { user.role = :staff; user }

  subject { Ability.new(user) }

  context 'when the user is a main user' do
    let(:user) { FactoryGirl.create(:user, :admin, :main) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:other_user_role_changed) { other_user.role = :admin; other_user }
    let(:admin_user_ready_to_create) { FactoryGirl.build :user, :admin }
    let(:admin_role_changed) { admin.role == :user; admin }

    it{ should be_able_to(:manage, User) }
    it{ should be_able_to(:manage, user) }
    it{ should be_able_to(:manage, other_user) }
    it{ should be_able_to(:update, other_user_role_changed) }
    it{ should be_able_to(:update, user_role_changed) }
    it{ should be_able_to(:create, admin_user_ready_to_create) }
    it{ should be_able_to(:update, admin) }
    it{ should be_able_to(:update, admin_role_changed) }
    it{ should be_able_to(:update, staff) }

    let(:client) { FactoryGirl.create(:client, creator: user) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator: other_user) }

    it{ should be_able_to(:manage, Client) }
    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:show, client) }
    it{ should be_able_to(:show, other_user_client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should be_able_to(:update, other_user_client) }
    it{ should be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:manage, Document) }
    it{ should be_able_to(:show, document_for_own_client) }
    it{ should be_able_to(:show, document_for_other_user_client) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should be_able_to(:create, document_for_other_user_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should be_able_to(:update, document_for_other_user_client) }
    it{ should be_able_to(:delete, document_for_own_client) }
    it{ should be_able_to(:delete, document_for_other_user_client) }

    let(:place) { FactoryGirl.create(:place, client: client) }
    let(:place_with_active_changed) { place.active = false; place }
    let(:other_user_place) { FactoryGirl.create(:place, client: other_user_client) }

    it{ should be_able_to(:manage, Place) }
    it{ should be_able_to(:index, Place) }
    it{ should be_able_to(:show, place) }
    it{ should be_able_to(:show, other_user_place) }
    it{ should be_able_to(:create, place) }
    it{ should be_able_to(:create, other_user_place) }
    it{ should be_able_to(:update, place) }
    it{ should be_able_to(:update, other_user_place) }
    it{ should be_able_to(:update, place_with_active_changed) }

    let(:rent) { FactoryGirl.create :rent, client: client, place: place, creator: user }
    let(:other_user_rent) { FactoryGirl.create :rent, client: client, place: place, creator: other_user }
    let(:other_user_client_rent) { FactoryGirl.create :rent, client: other_user_client, place: place, creator: user }
    let(:other_user_place_rent) { FactoryGirl.create :rent, client: client, place: other_user_place, creator: user }

    it{ should be_able_to(:manage, Rent) }
    it{ should be_able_to(:index, Rent) }
    it{ should be_able_to(:show, rent) }
    it{ should be_able_to(:create, rent) }
    it{ should be_able_to(:update, rent) }
    it{ should be_able_to(:show, other_user_rent) }
    it{ should be_able_to(:create, other_user_rent) }
    it{ should be_able_to(:create, other_user_client_rent) }
    it{ should be_able_to(:create, other_user_place_rent) }
    it{ should be_able_to(:update, other_user_rent) }
    it{ should be_able_to(:create, other_user_client_rent) }
    it{ should be_able_to(:create, other_user_place_rent) }
    it{ should be_able_to(:delete, Rent) }
  end

  context 'when the user is an admin or staff' do
    let(:user) { FactoryGirl.create(:user, :admin) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:other_user_role_changed) { other_user.role = :admin; other_user }
    let(:admin_user_ready_to_create) { FactoryGirl.build :user, :admin }
    let(:admin_degraded_to_user) { admin.role = :user; admin }

    it{ should be_able_to(:manage, User) }
    it{ should be_able_to(:manage, user) }
    it{ should be_able_to(:manage, other_user) }
    it{ should_not be_able_to(:update, other_user_role_changed) }
    it{ should_not be_able_to(:update, user_role_changed) }
    it{ should_not be_able_to(:create, admin_user_ready_to_create) }
    it{ should_not be_able_to(:update, admin) }
    it{ should_not be_able_to(:update, admin_degraded_to_user) }
    it{ should_not be_able_to(:update, staff) }

    let(:client) { FactoryGirl.create(:client, creator: user) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator: other_user) }

    it{ should be_able_to(:manage, Client) }
    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:show, client) }
    it{ should be_able_to(:show, other_user_client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should be_able_to(:update, other_user_client) }
    it{ should be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:manage, Document) }
    it{ should be_able_to(:show, document_for_own_client) }
    it{ should be_able_to(:show, document_for_other_user_client) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should be_able_to(:create, document_for_other_user_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should be_able_to(:update, document_for_other_user_client) }
    it{ should be_able_to(:delete, document_for_own_client) }
    it{ should be_able_to(:delete, document_for_other_user_client) }

    let(:place) { FactoryGirl.create(:place, client: client) }
    let(:place_with_active_changed) { place.active = false; place }
    let(:other_user_place) { FactoryGirl.create(:place, client: other_user_client) }

    it{ should be_able_to(:manage, Place) }
    it{ should be_able_to(:index, Place) }
    it{ should be_able_to(:show, place) }
    it{ should be_able_to(:show, other_user_place) }
    it{ should be_able_to(:create, place) }
    it{ should be_able_to(:create, other_user_place) }
    it{ should be_able_to(:update, place) }
    it{ should be_able_to(:update, other_user_place) }
    it{ should be_able_to(:update, place_with_active_changed) }

    let(:rent) { FactoryGirl.create :rent, client: client, place: place, creator: user }
    let(:other_user_rent) { FactoryGirl.create :rent, client: client, place: place, creator: other_user }
    let(:other_user_client_rent) { FactoryGirl.create :rent, client: other_user_client, place: place, creator: user }
    let(:other_user_place_rent) { FactoryGirl.create :rent, client: client, place: other_user_place, creator: user }

    it{ should be_able_to(:manage, Rent) }
    it{ should be_able_to(:index, Rent) }
    it{ should be_able_to(:show, rent) }
    it{ should be_able_to(:create, rent) }
    it{ should be_able_to(:update, rent) }
    it{ should be_able_to(:show, other_user_rent) }
    it{ should be_able_to(:create, other_user_rent) }
    it{ should be_able_to(:create, other_user_client_rent) }
    it{ should be_able_to(:create, other_user_place_rent) }
    it{ should be_able_to(:update, other_user_rent) }
    it{ should be_able_to(:create, other_user_client_rent) }
    it{ should be_able_to(:create, other_user_place_rent) }
    it{ should be_able_to(:delete, Rent) }
  end

  context 'when the user is just an user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    subject { Ability.new(user) }

    it{ should be_able_to(:read, user) }
    it{ should be_able_to(:update, user) }
    it{ should_not be_able_to(:update, user_role_changed) }
    it{ should_not be_able_to(:manage, other_user) }
    it{ should_not be_able_to(:index, User) }
    it{ should_not be_able_to(:show, User) }

    let(:client) { FactoryGirl.create(:client, creator: user) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator: other_user) }

    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:show, client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should_not be_able_to(:show, other_user_client) }
    it{ should_not be_able_to(:update, other_user_client) }
    it{ should_not be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:show, document_for_own_client) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should be_able_to(:delete, document_for_own_client) }
    it{ should_not be_able_to(:show, document_for_other_user_client) }
    it{ should_not be_able_to(:create, document_for_other_user_client) }
    it{ should_not be_able_to(:update, document_for_other_user_client) }
    it{ should_not be_able_to(:delete, document_for_other_user_client) }

    let(:place) { FactoryGirl.create(:place, client: client) }
    let(:place_with_active_changed) { place.active = false; place }
    let(:other_user_place) { FactoryGirl.create(:place, client: other_user_client) }

    it{ should be_able_to(:index, Place) }
    it{ should be_able_to(:show, place) }
    it{ should be_able_to(:create, place) }
    it{ should be_able_to(:update, place) }
    it{ should_not be_able_to(:show, other_user_place) }
    it{ should_not be_able_to(:create, other_user_place) }
    it{ should_not be_able_to(:update, other_user_place) }
    it{ should_not be_able_to(:update, place_with_active_changed) }

    let(:rent) { FactoryGirl.create :rent, client: client, place: place, creator: user }
    let(:other_user_rent) { FactoryGirl.create :rent, client: client, place: place, creator: other_user }
    let(:other_user_client_rent) { FactoryGirl.create :rent, client: other_user_client, place: place, creator: user }
    let(:other_user_place_rent) { FactoryGirl.create :rent, client: client, place: other_user_place, creator: user }

    it{ should be_able_to(:index, Rent) }
    it{ should be_able_to(:show, rent) }
    it{ should be_able_to(:create, rent) }
    it{ should be_able_to(:update, rent) }
    it{ should_not be_able_to(:show, other_user_rent) }
    it{ should_not be_able_to(:create, other_user_rent) }
    it{ should_not be_able_to(:create, other_user_client_rent) }
    it{ should_not be_able_to(:create, other_user_place_rent) }
    it{ should_not be_able_to(:update, other_user_rent) }
    it{ should_not be_able_to(:create, other_user_client_rent) }
    it{ should_not be_able_to(:create, other_user_place_rent) }
    it{ should_not be_able_to(:delete, Rent) }
  end
end
