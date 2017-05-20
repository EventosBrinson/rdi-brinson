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
  it { should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }

  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :address_line_1 }
  it { should validate_presence_of :telephone_1 }
  it { should validate_presence_of :id_name }
  it { should validate_inclusion_of(:id_name).in_array(Client::ID_NAMES) }
  it { should validate_presence_of :trust_level }
  it { should validate_inclusion_of(:trust_level).in_array((1..10).to_a) }

  describe '.active' do
    it 'returns all the active clients' do
      5.times { FactoryGirl.create :client }
      10.times { FactoryGirl.create :client, :inactive }
      
      expect(Client.active.count).to eq(5)
    end
  end

  describe '.inacive' do
    it 'returns all the inactive clients' do
      10.times { FactoryGirl.create :client }
      5.times { FactoryGirl.create :client, :inactive }
      
      expect(Client.inactive.count).to eq(5)
    end
  end

  describe '#active?' do
    it 'returns true if the client active attribute is true' do
      client = FactoryGirl.create :client, :active
      client2 = FactoryGirl.create :client, :inactive

      expect(client).to be_active
      expect(client2).to_not be_active
    end
  end

  describe '#activate!' do
    it 'updates the client active attribute to ture' do
      client = FactoryGirl.create :client, :inactive

      expect{ client.activate! }.to change(client, :active).from(false).to(true)
    end
  end

  describe '#deactivate!' do
    it 'updates the client active attribute to false' do
      client = FactoryGirl.create :client, :active

      expect{ client.deactivate! }.to change(client, :active).from(true).to(false)
    end
  end
end
