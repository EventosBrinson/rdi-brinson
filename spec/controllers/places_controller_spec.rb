require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  describe 'GET #index' do
    it 'returns the list of places that belongs to clients the user has created' do
      user = FactoryBot.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      user_client = ->() { FactoryBot.create :client, creator: user }

      5.times { FactoryBot.create :place, client: user_client.call }
      5.times { FactoryBot.create :place }

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :index

      expect(response).to be_successful
      expect(assigns(:places)).to_not be_nil
      expect(assigns(:places).size).to eq(5)
      expect(response).to render_template('places/index.json')
    end

    context 'when the search param is present' do
      it 'returns a list of places that match the query' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryBot.create :client, creator: user }

        FactoryBot.create :place, name: 'AAB', street: 'BBC'
        FactoryBot.create :place, name: 'BAA', street: 'AAB'
        FactoryBot.create :place, name: 'ZZA', street: 'XXF'

        match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
        match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
        not_match_place = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { search: 'AAB' }

        expect(response).to be_successful
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(2)
        expect(response).to render_template('places/index.json')
      end
    end

    context 'when the order param is present' do
      it 'returns a list of places ordered by a field name' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryBot.create :client, creator: user }

        FactoryBot.create :place, name: 'AAB', street: 'BBC'
        FactoryBot.create :place, name: 'BAA', street: 'AAB'
        FactoryBot.create :place, name: 'ZZA', street: 'XXF'

        match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
        match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
        match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { ordered: { street: :desc }}

        expect(response).to be_successful
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(3)
        expect(assigns(:places).first).to eq(match_place3)
        expect(response).to render_template('places/index.json')
      end


      context 'but is erratic' do
        it 'returns a list of places ordered by the default' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = ->() { FactoryBot.create :client, creator: user }

          FactoryBot.create :place, name: 'AAB', street: 'BBC'
          FactoryBot.create :place, name: 'BAA', street: 'AAB'
          FactoryBot.create :place, name: 'ZZA', street: 'XXF'

          match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
          match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
          match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { not_a_column: :desc }}

          expect(response).to be_successful
          expect(assigns(:places)).to_not be_nil
          expect(assigns(:places).size).to eq(3)
          expect(assigns(:places).first).to eq(match_place1)
          expect(response).to render_template('places/index.json')
        end
      end
    end

    context 'when the paginated param is present' do
      it 'returns a list of clients with the offset and limit specified' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        user_client = ->() { FactoryBot.create :client, creator: user }

        FactoryBot.create :place, name: 'AAB', street: 'BBC'
        FactoryBot.create :place, name: 'BAA', street: 'AAB'
        FactoryBot.create :place, name: 'ZZA', street: 'XXF'

        match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
        match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
        match_place4 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { paginated: { offset: 0, limit: 2 } }

        expect(response).to be_successful
        expect(assigns(:places)).to_not be_nil
        expect(assigns(:places).size).to eq(2)
        expect(assigns(:places).first).to eq(match_place1)
        expect(response).to render_template('places/index.json')
      end

      context 'but the range is erratic' do
        it 'returns what can be returned with that range' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = ->() { FactoryBot.create :client, creator: user }

          FactoryBot.create :place, name: 'AAB', street: 'BBC'
          FactoryBot.create :place, name: 'BAA', street: 'AAB'
          FactoryBot.create :place, name: 'ZZA', street: 'XXF'

          match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
          match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
          match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 2, limit: 10 }}

          expect(response).to be_successful
          expect(assigns(:places)).to_not be_nil
          expect(assigns(:places).size).to eq(1)
          expect(assigns(:places).first).to eq(match_place3)
          expect(response).to render_template('places/index.json')
        end
      end
    end

    context 'and the "all" param is present' do
      context ' and the current user has admin rights' do
        it 'returns the list of all places' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = ->() { FactoryBot.create :client, creator: user }

          5.times { FactoryBot.create :place, client: user_client.call }
          5.times { FactoryBot.create :place }

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { all: true }

          expect(response).to be_successful
          expect(assigns(:places)).to_not be_nil
          expect(assigns(:places).size).to eq(10)
          expect(response).to render_template('places/index.json')
        end

        context 'when the search param is present' do
          it 'returns a list of places that match the query' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC'
            match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB'
            not_match_place = FactoryBot.create :place, name: 'ZZA', street: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, search: 'AAB' }

            expect(response).to be_successful
            expect(assigns(:places)).to_not be_nil
            expect(assigns(:places).size).to eq(2)
            expect(response).to render_template('places/index.json')
          end
        end

        context 'when the order param is present' do
          it 'returns a list of places ordered by a field name' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC'
            match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB'
            match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, ordered: { street: :desc }}

            expect(response).to be_successful
            expect(assigns(:places)).to_not be_nil
            expect(assigns(:places).size).to eq(3)
            expect(assigns(:places).first).to eq(match_place3)
            expect(response).to render_template('places/index.json')
          end


          context 'but is erratic' do
            it 'returns a list of places ordered by the default' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC'
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB'
              match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, ordered: { not_a_column: :desc }}

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(3)
              expect(assigns(:places).first).to eq(match_place1)
              expect(response).to render_template('places/index.json')
            end
          end
        end

        context 'when the paginated param is present' do
          it 'returns a list of clients with the offset and limit specified' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC'
            match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB'
            match_place4 = FactoryBot.create :place, name: 'ZZA', street: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, paginated: { offset: 0, limit: 2 } }

            expect(response).to be_successful
            expect(assigns(:places)).to_not be_nil
            expect(assigns(:places).size).to eq(2)
            expect(assigns(:places).first).to eq(match_place1)
            expect(response).to render_template('places/index.json')
          end

          context 'but the range is erratic' do
            it 'returns what can be returned with that range' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC'
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB'
              match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, paginated: { offset: 2, limit: 10 }}

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(1)
              expect(assigns(:places).first).to eq(match_place3)
              expect(response).to render_template('places/index.json')
            end
          end
        end
      end
    end

    context 'and the client_id param is present' do
      context 'and the current user has admin rights' do
        context 'and the id is from a client the current user does not own' do
          it 'returns the list of places that belongs to the specified client' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            user_client = ->() { FactoryBot.create :client, creator: user  }
            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :place, client: user_client.call }
            5.times { FactoryBot.create :place, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_successful
            expect(assigns(:places)).to_not be_nil
            expect(assigns(:places).size).to eq(5)
            expect(response).to render_template('places/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of places that match the query' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              not_match_place = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(2) 
              expect(response).to render_template('places/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of places ordered by a field name' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { street: :desc }}

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(3)
              expect(assigns(:places).first).to eq(match_place3)
              expect(response).to render_template('places/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of places ordered by the default' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                user_client = ->() { FactoryBot.create :client, creator: user }
                specified_client = FactoryBot.create :client

                FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
                FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
                FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

                match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
                match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
                match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:places)).to_not be_nil
                expect(assigns(:places).size).to eq(3)
                expect(assigns(:places).first).to eq(match_place1)
                expect(response).to render_template('places/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              match_place4 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(2)
              expect(assigns(:places).first).to eq(match_place1)
              expect(response).to render_template('places/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                user_client = ->() { FactoryBot.create :client, creator: user }
                specified_client = FactoryBot.create :client

                FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
                FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
                FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

                match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
                match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
                match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:places)).to_not be_nil
                expect(assigns(:places).size).to eq(1)
                expect(assigns(:places).first).to eq(match_place3)
                expect(response).to render_template('places/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that does not exist' do
          it 'returns not found' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            user_client = ->() { FactoryBot.create :client, creator: user  }
            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :place, client: user_client.call }
            5.times { FactoryBot.create :place, client: specified_client }

            safe_id = Client.pluck(:id).reduce(0){ |sum, x| sum + x }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: safe_id }

            expect(response).to be_not_found
          end
        end
      end
      context 'and the current user is and average user' do
        context 'and the id is from a client the current user does own' do
          it 'returns the list of places that belongs to the specified client' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            user_client = ->() { FactoryBot.create :client, creator: user  }
            specified_client = FactoryBot.create :client, creator: user

            7.times { FactoryBot.create :place, client: user_client.call }
            5.times { FactoryBot.create :place, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_successful
            expect(assigns(:places)).to_not be_nil
            expect(assigns(:places).size).to eq(5)
            expect(response).to render_template('places/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of places that match the query' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              not_match_place = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(2) 
              expect(response).to render_template('places/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of places ordered by a field name' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { street: :desc }}

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(3)
              expect(assigns(:places).first).to eq(match_place3)
              expect(response).to render_template('places/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of places ordered by the default' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                user_client = ->() { FactoryBot.create :client, creator: user }
                specified_client = FactoryBot.create :client, creator: user

                FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
                FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
                FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

                match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
                match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
                match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:places)).to_not be_nil
                expect(assigns(:places).size).to eq(3)
                expect(assigns(:places).first).to eq(match_place1)
                expect(response).to render_template('places/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              user_client = ->() { FactoryBot.create :client, creator: user }
              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
              FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
              FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

              match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
              match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
              match_place4 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:places)).to_not be_nil
              expect(assigns(:places).size).to eq(2)
              expect(assigns(:places).first).to eq(match_place1)
              expect(response).to render_template('places/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                user_client = ->() { FactoryBot.create :client, creator: user }
                specified_client = FactoryBot.create :client, creator: user

                FactoryBot.create :place, name: 'AAB', street: 'BBC', client: user_client.call
                FactoryBot.create :place, name: 'BAA', street: 'AAB', client: user_client.call
                FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: user_client.call

                match_place1 = FactoryBot.create :place, name: 'AAB', street: 'BBC', client: specified_client
                match_place2 = FactoryBot.create :place, name: 'BAA', street: 'AAB', client: specified_client
                match_place3 = FactoryBot.create :place, name: 'ZZA', street: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:places)).to_not be_nil
                expect(assigns(:places).size).to eq(1)
                expect(assigns(:places).first).to eq(match_place3)
                expect(response).to render_template('places/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that the current user dows not own' do
          it 'returns forbidden' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            user_client = ->() { FactoryBot.create :client }
            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :place, client: user_client.call }
            5.times { FactoryBot.create :place, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_forbidden
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when the current user has admin rights' do
      context 'and the id is from other user place' do
        it 'returns the place data using the specified id' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_retrieve = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: place_to_retrieve.id }

          expect(response).to be_successful
          expect(assigns(:place)).to eq(place_to_retrieve)
          expect(response).to render_template('places/show.json')
        end
      end
      context 'the id is not from an actual place' do
        it 'returns 404' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: 969 }

          expect(response).to be_not_found
        end
      end
    end
    context 'when the current user is an average user' do
      context 'and the id is from a place the current user does own' do
        it 'returns the place data using the specified id' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_client = FactoryBot.create :client, creator: user
          place_to_retrieve = FactoryBot.create :place, client: user_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: place_to_retrieve.id }

          expect(response).to be_successful
          expect(assigns(:place)).to eq(place_to_retrieve)
          expect(response).to render_template('places/show.json')
        end
      end
      context 'and the id is from other user place' do
        it 'returns forbidden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_retrieve = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: place_to_retrieve.id }

          expect(response).to be_forbidden
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when the right place information is present' do
      it 'creates a new place' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        target_client = FactoryBot.create :client, creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        expect{ post :create, params: { place: FactoryBot.attributes_for(:place).merge({ client_id: target_client.id }) }}.to change{ Place.count }.by(1)
        expect(response).to be_successful
      end

      it 'returns a json object with the new place' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        target_client = FactoryBot.create :client, creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { place: FactoryBot.attributes_for(:place).merge({ client_id: target_client.id }) }
        
        expect(response).to be_successful
        expect(response).to render_template('places/show.json')
      end
    end

    context 'when the place information is erratic' do
      it 'does not create a new place' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :create, params: { place: { name: '', street: '' }}}.to_not change{ Place.count }
        expect(response).to be_successful
      end
      it 'returns the place errors json object' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { place: { name: '', street: '' }}

        expect(response.body).to_not be_empty
        expect(assigns(:place).errors).to_not be_empty
      end
    end

    context 'when the current user has admin rights' do
      context 'and the client id is from a client the user does not own' do
        it 'creates a new place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { place: FactoryBot.attributes_for(:place).merge({ client_id: target_client.id }) }}.to change{ Place.count }.by(1)
          expect(response).to be_successful
          expect(response).to render_template('places/show.json')
        end
      end
    end

    context 'when the current user is an average user' do
      context 'and the client id is from a client the user does not own' do
        it 'returns forbidden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { place: FactoryBot.attributes_for(:place).merge({ client_id: target_client.id }) }}.to_not change{ Place }
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe 'PATCH #Update' do
    context 'when the current user has admin rights' do
      context 'and the right place information is present' do
        it 'updates the place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          place_to_update.reload

          expect(place_to_update.name).to eq('Bombar')
          expect(place_to_update.street).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          expect(response).to render_template('places/show.json')
        end
      end

      context 'and the place information is erratic' do
        it 'does not updates the place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: '', street: '' } }

          previous_name = place_to_update.name
          place_to_update.reload

          expect(place_to_update.name).to eq(previous_name)
          expect(response).to be_successful
        end

        it 'returns the places errors json object' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: '', street: '' } }

          expect(response.body).to_not be_empty
          expect(assigns(:place).errors).to_not be_empty
        end
      end

      context 'and is changing a place created by other user' do
        it 'updates the place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_update = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          place_to_update.reload

          expect(place_to_update.name).to eq('Bombar')
          expect(place_to_update.street).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated place' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_update = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          expect(response).to render_template('places/show.json')
        end
      end
    end
    context 'when the current user is an average user' do
      context 'and is changing a place created by the current user (self)' do
        it 'updates the place' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          place_to_update.reload

          expect(place_to_update.name).to eq('Bombar')
          expect(place_to_update.street).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated place' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          expect(response).to render_template('places/show.json')
        end
      end

      context 'and is changing a place created by other user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_update = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { name: 'Bombar', street: 'De Anda' } }

          previous_name = place_to_update.name
          place_to_update.reload

          expect(place_to_update.name).to eq(previous_name)
          expect(response).to be_forbidden
        end
      end
    end
    context 'when the active param is present' do
      context 'and the current user is admin/staff user' do
        it 'changes the place active state' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          place_to_update = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { active: false } }

          place_to_update.reload

          expect(place_to_update).to_not be_active
          expect(response).to be_successful
        end
      end
      context 'and the current user is an average user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          place_to_update = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: place_to_update.id, place: { active: false } }

          place_to_update.reload

          expect(place_to_update).to be_active
          expect(response).to be_forbidden
        end
      end
    end
    context 'the id is not from an actual place' do
      it 'returns 404' do
        user = FactoryBot.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        patch :update, params: { id: 969 }

        expect(response).to be_not_found
      end
    end
  end
end
