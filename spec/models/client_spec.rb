require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { FactoryGirl.build :client }

  it { should have_db_column(:firstname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:lastname).of_type(:string).with_options(null: false) }
  it { should have_db_column(:street).of_type(:string).with_options(null: false) }
  it { should have_db_column(:inner_number).of_type(:string) }
  it { should have_db_column(:outer_number).of_type(:string).with_options(null: false) }
  it { should have_db_column(:neighborhood).of_type(:string).with_options(null: false) }
  it { should have_db_column(:postal_code).of_type(:string) }
  it { should have_db_column(:telephone_1).of_type(:string).with_options(null: false) }
  it { should have_db_column(:telephone_2).of_type(:string) }
  it { should have_db_column(:email).of_type(:string) }
  it { should have_db_column(:id_name).of_type(:string).with_options(null: false) }
  it { should have_db_column(:trust_level).of_type(:integer).with_options(null: false, default: 10) }
  it { should have_db_column(:rent_type).of_type(:integer).with_options(null: false) }
  it { should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }

  it { should belong_to(:creator).class_name('User') }
  it { should have_many(:documents) }
  it { should have_many(:places) }
  it { should have_many(:rents) }

  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :street }
  it { should validate_presence_of :outer_number }
  it { should validate_presence_of :neighborhood }
  it { should validate_presence_of :telephone_1 }
  it { should allow_value('omarandstuff@gmail.com').for(:email) }
  it { should allow_values(nil).for(:email) }
  it { should allow_values('').for(:email) }
  it { should_not allow_value('sometext').for(:email) }
  it { should validate_presence_of :id_name }
  it { should validate_inclusion_of(:id_name).in_array(Client::ID_NAMES) }
  it { should validate_presence_of :trust_level }
  it { should validate_inclusion_of(:trust_level).in_array((1..10).to_a) }
  it { should validate_presence_of :rent_type }
  it { should validate_presence_of :creator }

  it { should define_enum_for(:rent_type).with(Client::RENT_TYPES) }


  describe '#create_first_place' do
    it 'it create a place for this client based on the client information' do
      client = FactoryGirl.create :client

      client.create_first_place

      expect(client.places.size).to eq(1)
      expect(client.places.first.street).to eq(client.street)
      expect(client.places.first.inner_number).to eq(client.inner_number)
      expect(client.places.first.outer_number).to eq(client.outer_number)
      expect(client.places.first.neighborhood).to eq(client.neighborhood)
      expect(client.places.first.postal_code).to eq(client.postal_code)
    end
  end

  describe '#folio' do
    it 'return the AGS-[record id + special number] folio' do
      client = FactoryGirl.create :client

      expect(client.folio).to eq("AGS-#{client.id + 260786}")
    end
  end

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

  describe '.search' do
    it 'returns all clients that match the query' do
      client_match1 = FactoryGirl.create :client, firstname: 'david', lastname: 'de anda'
      client_match2 = FactoryGirl.create :client, firstname: 'DAVID', lastname: 'gomez'
      client_not_match = FactoryGirl.create :client, firstname: 'Roberto', lastname: 'Bolaños'

      expect(Client.search('david').size).to eq(2)
    end
  end

  describe '.paginated' do
    it 'returns all the clients between the offset and limit range' do
      client_match1 = FactoryGirl.create :client, firstname: 'david', lastname: 'de anda'
      client_match2 = FactoryGirl.create :client, firstname: 'DAVID', lastname: 'gomez'
      client_match3 = FactoryGirl.create :client, firstname: 'Roberto', lastname: 'Bolaños'
      client_match4 = FactoryGirl.create :client, firstname: 'Enrique', lastname: 'Segoviano'

      expect(Client.paginated(offset: 1, limit: 2).size).to eq(2)
    end
  end

  describe '.filter' do
    it 'returns all the clients filtered by params as messages and param value as message param' do
      client_match1 = FactoryGirl.create :client, firstname: 'david', lastname: 'de anda'
      client_match2 = FactoryGirl.create :client, firstname: 'DAVID', lastname: 'gomez'
      client_match3 = FactoryGirl.create :client, firstname: 'david', lastname: 'segoviano'
      client_match4 = FactoryGirl.create :client, firstname: 'david', lastname: 'zan'
      client_not_match = FactoryGirl.create :client, firstname: 'Roberto', lastname: 'Bolaños'

      clients_filtered = Client.filter({ search: 'david', order: { lastname: :desc }, paginated: { offset: 0, limit: 2 } })

      expect(clients_filtered.size).to eq(2)
      expect(clients_filtered.first).to eq(client_match4)
      expect(clients_filtered.last).to eq(client_match3)
    end
  end

  describe '.ordered' do
    context 'order hash contains actual columns to order' do
      it 'returns the clients ordered by the specified columns and orders' do
        client_match1 = FactoryGirl.create :client, firstname: 'david', lastname: 'De anda'
        client_match2 = FactoryGirl.create :client, firstname: 'DAVID', lastname: 'gomez'
        client_match3 = FactoryGirl.create :client, firstname: 'Roberto', lastname: 'de anda'

        clients_ordered = Client.ordered({ lastname: :desc, firstname: :asc })

        expect(clients_ordered.size).to eq(3)
        expect(clients_ordered.first).to eq(client_match2)
        expect(clients_ordered.second).to eq(client_match1)
        expect(clients_ordered.last).to eq(client_match3)
      end
    end
  end

  describe '#fullname' do
    it 'returns the client fullname (firstname lastname)' do
      client = FactoryGirl.create :client

      expect(client.fullname).to eq [client.firstname, client.lastname].join(' ')
    end
  end

  describe '#formated_rent_type' do
    it 'returns the client rent type in its formated version' do
      Client::RENT_TYPES.each do |rent_type|
        client = FactoryGirl.create :client, rent_type: rent_type

        expect(client.formated_rent_type).to eq(Client::FORMATED_RENT_TYPES[rent_type])
      end
    end
  end
end
