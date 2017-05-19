require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { FactoryGirl.build :client }

  it { should have_db_column(:firstname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:lastname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:address_line_1).of_type(:string).with_options(null: false) }
  it { should have_db_column(:address_line_2).of_type(:string) }
  it { should have_db_column(:telephone_1).of_type(:string).with_options(null: false) }
  it { should have_db_column(:telephone_2).of_type(:string) }
  it { should have_db_column(:id_name).of_type(:string).with_options(null: false) }
  it { should have_db_column(:trust_level).of_type(:integer).with_options(null: false, default: 10) }

  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :address_line_1 }
  it { should validate_presence_of :telephone_1 }
  it { should validate_presence_of :id_name }
  it { should validate_inclusion_of(:id_name).in_array(Client::ID_NAMES) }
  it { should validate_presence_of :trust_level }
  it { should validate_inclusion_of(:trust_level).in_array((1..10).to_a) }
end
