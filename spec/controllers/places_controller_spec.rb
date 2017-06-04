require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  describe 'GET #index' do
    it 'returns the list of places that belongs to clients the user has created' do
      user = FactoryGirl.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      user_client = ->() { FactoryGirl.create(:client, creator: user) }

      5.times { FactoryGirl.create :place, client: user_client.call }
      5.times { FactoryGirl.create :place }

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :index

      expect(response).to be_success
      expect(assigns(:places)).to_not be_nil
      expect(assigns(:places).size).to eq(5)
      expect(response).to render_template('places/index.json')
    end

    context 'when the search param is present' do
      it 'returns a list of places that match the query' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryGirl.create(:client, creator: user) }

        FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC'
        FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB'
        FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF'

        match_place1 = FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC', client: user_client.call
        match_place2 = FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB', client: user_client.call
        not_match_place = FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { search: 'AAB' }

        expect(response).to be_success
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(2)
        expect(response).to render_template('places/index.json')
      end
    end

    context 'when the order param is present' do
      it 'returns a list of places ordered by a field name' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryGirl.create(:client, creator: user) }

        FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC'
        FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB'
        FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF'

        match_place1 = FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC', client: user_client.call
        match_place2 = FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB', client: user_client.call
        match_place3 = FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { ordered: { address_line_1: :desc }}

        expect(response).to be_success
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(3)
        expect(assigns(:places).first).to eq(match_place3)
        expect(response).to render_template('places/index.json')
      end


      context 'but is erratic' do
        it 'returns a list of places ordered by the default' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = ->() { FactoryGirl.create(:client, creator: user) }

          FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC'
          FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB'
          FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF'

          match_place1 = FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC', client: user_client.call
          match_place2 = FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB', client: user_client.call
          match_place3 = FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF', client: user_client.call

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { not_a_column: :desc }}

          expect(response).to be_success
          expect(assigns(:places)).to_not be_nil
          expect(assigns(:places).size).to eq(3)
          expect(assigns(:places).first).to eq(match_place1)
          expect(response).to render_template('places/index.json')
        end
      end
    end

    context 'when the paginated param is present' do
      it 'returns a list of clients with the offset and limit specified' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryGirl.create(:client, creator: user) }

        FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC'
        FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB'
        FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF'

        match_place1 = FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC', client: user_client.call
        match_place2 = FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB', client: user_client.call
        match_place4 = FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { paginated: { offset: 0, limit: 2 } }

        expect(response).to be_success
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(2)
        expect(assigns(:places).first).to eq(match_place1)
        expect(response).to render_template('places/index.json')
      end

      context 'but the range is erratic' do
        it 'returns what can be returned with that range' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = ->() { FactoryGirl.create(:client, creator: user) }

          FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC'
          FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB'
          FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF'

          match_place1 = FactoryGirl.create :place, name: 'AAB', address_line_1: 'BBC', client: user_client.call
          match_place2 = FactoryGirl.create :place, name: 'BAA', address_line_1: 'AAB', client: user_client.call
          match_place3 = FactoryGirl.create :place, name: 'ZZA', address_line_1: 'XXF', client: user_client.call

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 2, limit: 10 }}

          expect(response).to be_success
          expect(assigns(:places)).to_not be_nil
          expect(assigns(:places).size).to eq(1)
          expect(assigns(:places).first).to eq(match_place3)
          expect(response).to render_template('places/index.json')
        end
      end
    end
  end
end
