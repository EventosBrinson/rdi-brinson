require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.build :user }

  it { should have_db_column(:username).of_type(:string).with_options(null: false) }
  it { should have_db_column(:email).of_type(:string).with_options(null: false) }
  it { should have_db_column(:password_digest).of_type(:string).with_options(null: false) }
  it { should have_db_column(:firstname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:lastname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:role).of_type(:integer).with_options(null: false) }
  it { should have_db_column(:reset_password_token).of_type(:string) }
  it { should have_db_column(:reset_password_sent_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_token).of_type(:string) }
  it { should have_db_column(:confirmed_at).of_type(:datetime) }
  it { should have_db_column(:confirmation_sent_at).of_type(:datetime) }
  it { should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { should have_db_index(:username).unique }
  it { should have_db_index(:email).unique }
  it { should have_db_index(:reset_password_token).unique }
  it { should have_db_index(:confirmation_token).unique }

  it { should validate_presence_of :username }
  it { should validate_uniqueness_of(:username) }
  it { should allow_value('omarandstuff').for(:username) }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :role }
  it { should have_secure_password }
  it { should validate_length_of(:password).is_at_least(8).is_at_most(256) }

  it { should define_enum_for(:role).with(User::ROLES) }
end
