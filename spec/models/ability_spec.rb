require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:staff) { FactoryGirl.create(:user, :staff) }
  let(:main) { FactoryGirl.create(:user, :admin, :main) }

  let(:user_role_changed) { user.role = :staff; user }

  subject { Ability.new(user) }

  context 'when the user is an admin or staff' do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it{ should be_able_to(:manage, User) }
    it{ should be_able_to(:manage, user) }
    it{ should_not be_able_to(:update, user_role_changed) }
    it{ should_not be_able_to(:update, admin) }
    it{ should_not be_able_to(:update, staff) }
  end

  context 'when the user is just an user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    subject { Ability.new(user) }

    it{ should be_able_to(:read, user) }
    it{ should be_able_to(:update, user) }
    it{ should_not be_able_to(:update, user_role_changed) }
    it{ should_not be_able_to(:manage, other_user) }
  end
end
