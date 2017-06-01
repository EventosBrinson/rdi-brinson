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

    let(:client) { FactoryGirl.create(:client, creator_id: user.id) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator_id: other_user.id) }

    it{ should be_able_to(:manage, Client) }
    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should be_able_to(:update, other_user_client) }
    it{ should be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:manage, Document) }
    it{ should be_able_to(:show, Document) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should be_able_to(:create, document_for_other_user_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should be_able_to(:update, document_for_other_user_client) }
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

    let(:client) { FactoryGirl.create(:client, creator_id: user.id) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator_id: other_user.id) }

    it{ should be_able_to(:manage, Client) }
    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should be_able_to(:update, other_user_client) }
    it{ should be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:manage, Document) }
    it{ should be_able_to(:show, Document) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should be_able_to(:create, document_for_other_user_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should be_able_to(:update, document_for_other_user_client) }
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

    let(:client) { FactoryGirl.create(:client, creator_id: user.id) }
    let(:client_with_active_changed) { client.active = false; client }
    let(:other_user_client) { FactoryGirl.create(:client, creator_id: other_user.id) }

    it{ should be_able_to(:index, Client) }
    it{ should be_able_to(:create, Client) }
    it{ should be_able_to(:update, client) }
    it{ should_not be_able_to(:update, other_user_client) }
    it{ should_not be_able_to(:update, client_with_active_changed) }

    let(:document_for_own_client) { FactoryGirl.create :document, client: client }
    let(:document_for_other_user_client) { FactoryGirl.create :document, client: other_user_client }

    it{ should be_able_to(:show, Document) }
    it{ should be_able_to(:create, document_for_own_client) }
    it{ should_not be_able_to(:create, document_for_other_user_client) }
    it{ should be_able_to(:update, document_for_own_client) }
    it{ should_not be_able_to(:update, document_for_other_user_client) }
  end
end
