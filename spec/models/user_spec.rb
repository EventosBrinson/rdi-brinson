require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.build :user }

  it { should have_db_column(:username).of_type(:string).with_options(null: false) }
  it { should have_db_column(:email).of_type(:string).with_options(null: false) }
  it { should have_db_column(:password_digest).of_type(:string) }
  it { should have_db_column(:firstname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:lastname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:role).of_type(:integer).with_options(null: false) }
  it { should have_db_column(:main).of_type(:boolean).with_options(null: false, default: false) }
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
  it { should_not allow_value('omarandstuff@something.com').for(:username) }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email) }
  it { should allow_value('omarandstuff@gmail.com').for(:email) }
  it { should_not allow_value('sometext').for(:email) }
  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :role }
  it { should have_secure_password }
  it { should validate_length_of(:password).is_at_least(8).is_at_most(256) }
  it { should allow_value(nil).for(:password) }

  it { should define_enum_for(:role).with(User::ROLES) }

  describe '.search' do
    it 'returns all user that match the query' do
      user_match1 = FactoryGirl.create :user, firstname: 'david', lastname: 'de anda'
      user_match2 = FactoryGirl.create :user, firstname: 'DAVID', lastname: 'gomez'
      user_not_match = FactoryGirl.create :user, firstname: 'Roberto', lastname: 'Bolaños'

      expect(User.search('david').size).to eq(2)
    end
  end

  describe '.filter' do
    it 'returns all the users filtered by params as messages and param value as message param' do
      user_match1 = FactoryGirl.create :user, firstname: 'david', lastname: 'de anda'
      user_match2 = FactoryGirl.create :user, firstname: 'DAVID', lastname: 'gomez'
      user_not_match = FactoryGirl.create :user, firstname: 'Roberto', lastname: 'Bolaños'

      p User.filter({ search: 'david', order: { lastname: :desc } }).to_sql

      users_filtered = User.filter({ search: 'david', order: { lastname: :desc } })

      expect(users_filtered.size).to eq(2)
      expect(users_filtered.first).to eq(user_match2)
      expect(users_filtered.last).to eq(user_match1)
    end
  end

  describe '.ordered' do
    context 'order hash contains actual columns to order' do
      it 'returns the users ordered by the specified columns and orders' do
        user_match1 = FactoryGirl.create :user, firstname: 'david', lastname: 'De anda'
        user_match2 = FactoryGirl.create :user, firstname: 'DAVID', lastname: 'gomez'
        user_match3 = FactoryGirl.create :user, firstname: 'Roberto', lastname: 'de anda'

        users_filtered = User.ordered({ lastname: :desc, firstname: :asc })

        expect(users_filtered.size).to eq(3)
        expect(users_filtered.first).to eq(user_match2)
        expect(users_filtered.second).to eq(user_match1)
        expect(users_filtered.last).to eq(user_match3)
      end
    end
  end

  describe '.find_by_credential' do
    it 'returns the first record which username or password match the credential param' do
      user = FactoryGirl.create :user

      expect(User.find_by_credential(user.username)).to eq(user)
      expect(User.find_by_credential(user.email)).to eq(user)
    end
  end

  describe '#confirmed?' do
    it 'returns true if the user confirmed_at attribute is set' do
      user = FactoryGirl.create :user, confirmed_at: Time.now

      expect(user.confirmed?).to eq true
    end
  end

  describe '#fullname' do
    it 'returns the user fullname (firstname lastname)' do
      user = FactoryGirl.create :user

      expect(user.fullname).to eq [user.firstname, user.lastname].join(' ')
    end
  end

  describe '#pending' do
    it 'returns true if the user confirmation_token and confirmation_sent_at attributes are set' do
      user = FactoryGirl.create :user, :confirmation_open

      expect(user).to be_pending
    end
  end

  describe '#reset_password_requested?' do
    it 'returns true if the user reset_password_token and reset_password_sent_at attributes are set' do
      user = FactoryGirl.create :user, :reset_password_requested

      expect(user).to be_reset_password_requested
    end
  end
end
