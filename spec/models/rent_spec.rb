require 'rails_helper'

RSpec.describe Rent, type: :model do
  subject { FactoryGirl.build :rent }

  it { should have_db_column(:delivery_time).of_type(:datetime).with_options(null: false) }
  it { should have_db_column(:pick_up_time).of_type(:datetime).with_options(null: false) }
  it { should have_db_column(:product).of_type(:text).with_options(null: false) }
  it { should have_db_column(:price).of_type(:decimal).with_options(null: false) }
  it { should have_db_column(:discount).of_type(:decimal) }
  it { should have_db_column(:additional_charges).of_type(:decimal) }
  it { should have_db_column(:additional_charges_notes).of_type(:text) }
  it { should have_db_column(:rent_type).of_type(:integer) }
  it { should have_db_column(:status).of_type(:integer) }

  it { should belong_to(:client) }
  it { should belong_to(:place) }

  it { should validate_presence_of :delivery_time }
  it { should validate_presence_of :pick_up_time }
  it { should validate_presence_of :product }
  it { should validate_presence_of :price }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:discount).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:additional_charges).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of :rent_type }
  it { should validate_presence_of :status }

  it { should define_enum_for(:rent_type).with(Client::RENT_TYPES) }
  it { should define_enum_for(:status).with(Rent::STATUSES) }
end
