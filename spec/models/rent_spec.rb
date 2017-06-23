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
  it { should have_db_column(:cancel_notes).of_type(:text) }
  it { should have_db_column(:rent_type).of_type(:integer) }
  it { should have_db_column(:status).of_type(:integer) }

  it { should belong_to(:client) }
  it { should belong_to(:creator).class_name('User') }

  it { should validate_presence_of :delivery_time }
  it { should validate_presence_of :pick_up_time }
  it { should validate_presence_of :product }
  it { should validate_presence_of :price }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:discount).is_greater_than_or_equal_to(0).allow_nil }
  it { should validate_numericality_of(:additional_charges).is_greater_than_or_equal_to(0).allow_nil }
  it { should validate_presence_of :client }
  it { should validate_presence_of :creator }

  it { should define_enum_for(:rent_type).with(Client::RENT_TYPES) }
  it { should define_enum_for(:status).with(Rent::STATUSES) }

  describe '#order_number' do
    it 'return the [record id + special number] order number' do
      rent = FactoryGirl.create :rent

      expect(rent.order_number).to eq("#{rent.id + 260786}")
    end
  end

  describe '#set_rent_type_from_client' do
    it 'is set before validation' do
      rent = FactoryGirl.build :rent

      expect(rent).to receive(:set_rent_type_from_client)
      rent.save
    end

    it 'sets the rent_type attribute from the client before validation' do
      rent = FactoryGirl.build :rent

      expect{ rent.save }.to change(rent, :rent_type).from(nil).to(rent.client.rent_type)
    end
  end

  describe '#init_status' do
    it 'is set before validation' do
      rent = FactoryGirl.build :rent

      expect(rent).to receive(:init_status)
      rent.save
    end

    it 'sets the status to reserved before validation on create' do
      rent = FactoryGirl.build :rent

      expect{ rent.save }.to change(rent, :status).from(nil).to('reserved')
    end
  end

  describe '#status_transition' do
    context 'changing from reserved to on_route' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent

        rent.status = :on_route
        expect(rent).to be_valid
      end
    end
    context 'changing from on_route to delivered' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_route

        rent.status = :delivered
        expect(rent).to be_valid
      end
    end
    context 'changing from delivered to on_pick_up' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :delivered

        rent.status = :on_pick_up
        expect(rent).to be_valid
      end
    end
    context 'changing from on_pick_up to pending' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_pick_up

        rent.status = :on_pick_up
        expect(rent).to be_valid
      end
    end
    context 'changing from pending to on_pick_up' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :pending

        rent.status = :on_pick_up
        expect(rent).to be_valid
      end
    end
    context 'changing from on_pick_up to finalized' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_pick_up

        rent.status = :finalized
        expect(rent).to be_valid
      end
    end

    context 'changing from reserved to canceled' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent

        rent.status = :canceled
        expect(rent).to be_valid
      end
    end
    context 'changing from on_route to canceled' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_route

        rent.status = :canceled
        expect(rent).to be_valid
      end
    end
    context 'changing from delivered to canceled' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :delivered

        rent.status = :canceled
        expect(rent).to be_valid
      end
    end
    context 'changing from on_pick_up to canceled' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_pick_up

        rent.status = :canceled
        expect(rent).to be_valid
      end
    end
    context 'changing from pending to canceled' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :pending

        rent.status = :canceled
        expect(rent).to be_valid
      end
    end

    context 'changing from on_route to reserved' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_route

        rent.status = :reserved
        expect(rent).to_not be_valid
      end
    end
    context 'changing from delivered to on_route' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :delivered

        rent.status = :on_route
        expect(rent).to_not be_valid
      end
    end
    context 'changing from on_pick_up to delivered' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :on_pick_up

        rent.status = :delivered
        expect(rent).to_not be_valid
      end
    end
    context 'changing from pending to delivered' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :pending

        rent.status = :delivered
        expect(rent).to_not be_valid
      end
    end
    context 'changing from finalized to on_pick_up' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :finalized

        rent.status = :on_pick_up
        expect(rent).to_not be_valid
      end
    end

    context 'changing from canceled to on_pick_up' do
      it 'should be valid' do
        rent = FactoryGirl.create :rent
        rent.update status: :canceled

        rent.status = :on_pick_up
        expect(rent).to_not be_valid
      end
    end
  end

  describe '.search' do
    it 'returns all rents that match the query' do
      rent_match1 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'de anda'
      rent_match2 = FactoryGirl.create :rent, product: 'DAVID', additional_charges_notes: 'gomez'
      rent_not_match = FactoryGirl.create :rent, product: 'Roberto', additional_charges_notes: 'Bolaños'

      expect(Rent.search('david').size).to eq(2)
    end
  end

  describe '.paginated' do
    it 'returns all the rents between the offset and limit range' do
      rent_match1 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'de anda'
      rent_match2 = FactoryGirl.create :rent, product: 'DAVID', additional_charges_notes: 'gomez'
      rent_match3 = FactoryGirl.create :rent, product: 'Roberto', additional_charges_notes: 'Bolaños'
      rent_match4 = FactoryGirl.create :rent, product: 'Enrique', additional_charges_notes: 'Segoviano'

      expect(Rent.paginated(offset: 1, limit: 2).size).to eq(2)
    end
  end

  describe '.filter' do
    it 'returns all the rents filtered by params as messages and param value as message param' do
      rent_match1 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'de anda'
      rent_match2 = FactoryGirl.create :rent, product: 'DAVID', additional_charges_notes: 'gomez'
      rent_match3 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'segoviano'
      rent_match4 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'zan'
      rent_not_match = FactoryGirl.create :rent, product: 'Roberto', additional_charges_notes: 'Bolaños'

      rents_filtered = Rent.filter({ search: 'david', order: { additional_charges_notes: :desc }, paginated: { offset: 0, limit: 2 } })

      expect(rents_filtered.size).to eq(2)
      expect(rents_filtered.first).to eq(rent_match4)
      expect(rents_filtered.last).to eq(rent_match3)
    end
  end

  describe '.ordered' do
    context 'order hash contains actual columns to order' do
      it 'returns the rents ordered by the specified columns and orders' do
        rent_match1 = FactoryGirl.create :rent, product: 'david', additional_charges_notes: 'De anda'
        rent_match2 = FactoryGirl.create :rent, product: 'DAVID', additional_charges_notes: 'gomez'
        rent_match3 = FactoryGirl.create :rent, product: 'Roberto', additional_charges_notes: 'de anda'

        rents_ordered = Rent.ordered({ additional_charges_notes: :desc, product: :asc })

        expect(rents_ordered.size).to eq(3)
        expect(rents_ordered.first).to eq(rent_match2)
        expect(rents_ordered.second).to eq(rent_match1)
        expect(rents_ordered.last).to eq(rent_match3)
      end
    end
  end
end
