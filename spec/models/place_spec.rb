require 'rails_helper'

RSpec.describe Place, type: :model do
  subject { FactoryGirl.build :place }

  it { should have_db_column(:name).of_type(:string).with_options(null: false) }
  it { should have_db_column(:address_line_1).of_type(:string).with_options(null: false) }
  it { should have_db_column(:address_line_2).of_type(:string) }
  it { should have_db_column(:latitude).of_type(:decimal).with_options(precision: 10, scale: 6) }
  it { should have_db_column(:longitude).of_type(:decimal).with_options(precision: 10, scale: 6) }
  it { should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }

  it { should belong_to(:client) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :address_line_1 }
  it { should validate_presence_of :client }
end
