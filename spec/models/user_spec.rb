require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_db_column(:username).of_type(:string).with_options(null: false) }
  it { should have_db_column(:email).of_type(:string).with_options(null: false) }
  it { should have_db_column(:password_digest).of_type(:string).with_options(null: false) }
  it { should have_db_column(:firstname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:lastname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:role).of_type(:string).with_options(null: false) }
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
end
