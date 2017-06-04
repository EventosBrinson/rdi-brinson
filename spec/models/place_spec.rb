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

  describe '.active' do
    it 'returns all the active places' do
      5.times { FactoryGirl.create :place }
      10.times { FactoryGirl.create :place, :inactive }
      
      expect(Place.active.count).to eq(5)
    end
  end

  describe '.inacive' do
    it 'returns all the inactive places' do
      10.times { FactoryGirl.create :place }
      5.times { FactoryGirl.create :place, :inactive }
      
      expect(Place.inactive.count).to eq(5)
    end
  end

  describe '#active?' do
    it 'returns true if the place active attribute is true' do
      place = FactoryGirl.create :place, :active
      place2 = FactoryGirl.create :place, :inactive

      expect(place).to be_active
      expect(place2).to_not be_active
    end
  end

  describe '#activate!' do
    it 'updates the place active attribute to ture' do
      place = FactoryGirl.create :place, :inactive

      expect{ place.activate! }.to change(place, :active).from(false).to(true)
    end
  end

  describe '#deactivate!' do
    it 'updates the place active attribute to false' do
      place = FactoryGirl.create :place, :active

      expect{ place.deactivate! }.to change(place, :active).from(true).to(false)
    end
  end

  describe '.search' do
    it 'returns all places that match the query' do
      place_match1 = FactoryGirl.create :place, name: 'david', address_line_1: 'de anda'
      place_match2 = FactoryGirl.create :place, name: 'DAVID', address_line_1: 'gomez'
      place_not_match = FactoryGirl.create :place, name: 'Roberto', address_line_1: 'Bolaños'

      expect(Place.search('david').size).to eq(2)
    end
  end

  describe '.paginated' do
    it 'returns all the places between the offset and limit range' do
      place_match1 = FactoryGirl.create :place, name: 'david', address_line_1: 'de anda'
      place_match2 = FactoryGirl.create :place, name: 'DAVID', address_line_1: 'gomez'
      place_match3 = FactoryGirl.create :place, name: 'Roberto', address_line_1: 'Bolaños'
      place_match4 = FactoryGirl.create :place, name: 'Enrique', address_line_1: 'Segoviano'

      expect(Place.paginated(offset: 1, limit: 2).size).to eq(2)
    end
  end

  describe '.filter' do
    it 'returns all the places filtered by params as messages and param value as message param' do
      place_match1 = FactoryGirl.create :place, name: 'david', address_line_1: 'de anda'
      place_match2 = FactoryGirl.create :place, name: 'DAVID', address_line_1: 'gomez'
      place_match3 = FactoryGirl.create :place, name: 'david', address_line_1: 'segoviano'
      place_match4 = FactoryGirl.create :place, name: 'david', address_line_1: 'zan'
      place_not_match = FactoryGirl.create :place, name: 'Roberto', address_line_1: 'Bolaños'

      places_filtered = Place.filter({ search: 'david', order: { address_line_1: :desc }, paginated: { offset: 0, limit: 2 } })

      expect(places_filtered.size).to eq(2)
      expect(places_filtered.first).to eq(place_match4)
      expect(places_filtered.last).to eq(place_match3)
    end
  end

  describe '.ordered' do
    context 'order hash contains actual columns to order' do
      it 'returns the places ordered by the specified columns and orders' do
        place_match1 = FactoryGirl.create :place, name: 'david', address_line_1: 'De anda'
        place_match2 = FactoryGirl.create :place, name: 'DAVID', address_line_1: 'gomez'
        place_match3 = FactoryGirl.create :place, name: 'Roberto', address_line_1: 'de anda'

        places_ordered = Place.ordered({ address_line_1: :desc, name: :asc })

        expect(places_ordered.size).to eq(3)
        expect(places_ordered.first).to eq(place_match2)
        expect(places_ordered.second).to eq(place_match1)
        expect(places_ordered.last).to eq(place_match3)
      end
    end
  end
end
