require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  describe 'GET #index' do
    it 'returns the list of clients the user has created' do
      user = FactoryGirl.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      5.times { FactoryGirl.create :client, creator: user }
      5.times { FactoryGirl.create :client }

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :index

      expect(response).to be_success
      expect(assigns(:clients)).to_not be_nil
      expect(assigns(:clients).size).to eq(5)
      expect(response).to render_template('clients/index.json')
    end

    context 'when the search param is present' do
      it 'returns a list of clients that match the query' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
        FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
        FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

        match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
        match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
        not_match_client = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { search: 'AAB' }

        expect(response).to be_success
        expect(assigns(:clients)).to_not be_nil
        expect(assigns(:clients).size).to eq(2)
        expect(response).to render_template('clients/index.json')
      end
    end

    context 'when the order param is present' do
      it 'returns a list of clients ordered by a field name' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
        FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
        FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

        match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
        match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
        match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { ordered: { lastname: :desc }}

        expect(response).to be_success
        expect(assigns(:clients)).to_not be_nil
        expect(assigns(:clients).size).to eq(3)
        expect(assigns(:clients).first).to eq(match_client3)
        expect(response).to render_template('clients/index.json')
      end


      context 'but is erratic' do
        it 'returns a list of clients ordered by the default' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
          FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
          FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

          match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
          match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
          match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { not_a_column: :desc }}

          expect(response).to be_success
          expect(assigns(:clients)).to_not be_nil
          expect(assigns(:clients).size).to eq(3)
          expect(assigns(:clients).first).to eq(match_client1)
          expect(response).to render_template('clients/index.json')
        end
      end
    end

    context 'when the paginated param is present' do
      it 'returns a list of clients with the offset and limit specified' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
        FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
        FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

        match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
        match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
        match_client4 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { paginated: { offset: 0, limit: 2 } }

        expect(response).to be_success
        expect(assigns(:clients)).to_not be_nil
        expect(assigns(:clients).size).to eq(2)
        expect(assigns(:clients).first).to eq(match_client1)
        expect(response).to render_template('clients/index.json')
      end

      context 'but the range is erratic' do
        it 'returns what can be returned with that range' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
          FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
          FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

          match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
          match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
          match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 2, limit: 10 }}

          expect(response).to be_success
          expect(assigns(:clients)).to_not be_nil
          expect(assigns(:clients).size).to eq(1)
          expect(assigns(:clients).first).to eq(match_client3)
          expect(response).to render_template('clients/index.json')
        end
      end
    end

    context 'and the "all" param is present' do
      context ' and the current user has admin rights' do
        it 'returns the list of all clients' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          5.times { FactoryGirl.create :client, creator: user }
          5.times { FactoryGirl.create :client }

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { all: true }

          expect(response).to be_success
          expect(assigns(:clients)).to_not be_nil
          expect(assigns(:clients).size).to eq(10)
          expect(response).to render_template('clients/index.json')
        end

        context 'when the search param is present' do
          it 'returns a list of clients that match the query' do
            user = FactoryGirl.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            not_match_client = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, search: 'AAB' }

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(2)
            expect(response).to render_template('clients/index.json')
          end
        end

        context 'when the order param is present' do
          it 'returns a list of clients ordered by a field name' do
            user = FactoryGirl.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, ordered: { lastname: :desc }}

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(3)
            expect(assigns(:clients).first).to eq(match_client3)
            expect(response).to render_template('clients/index.json')
          end


          context 'but is erratic' do
            it 'returns a list of clients ordered by the default' do
              user = FactoryGirl.create :user, :confirmed, :staff
              token = Sessions::Create.for credential: user.username, password: user.password

              match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
              match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
              match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, ordered: { not_a_column: :desc }}

              expect(response).to be_success
              expect(assigns(:clients)).to_not be_nil
              expect(assigns(:clients).size).to eq(3)
              expect(assigns(:clients).first).to eq(match_client1)
              expect(response).to render_template('clients/index.json')
            end
          end
        end

        context 'when the paginated param is present' do
          it 'returns a list of clients with the offset and limit specified' do
            user = FactoryGirl.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            match_client4 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, paginated: { offset: 0, limit: 2 } }

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(2)
            expect(assigns(:clients).first).to eq(match_client1)
            expect(response).to render_template('clients/index.json')
          end

          context 'but the range is erratic' do
            it 'returns what can be returned with that range' do
              user = FactoryGirl.create :user, :confirmed, :staff
              token = Sessions::Create.for credential: user.username, password: user.password

              match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
              match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
              match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, paginated: { offset: 2, limit: 10 }}

              expect(response).to be_success
              expect(assigns(:clients)).to_not be_nil
              expect(assigns(:clients).size).to eq(1)
              expect(assigns(:clients).first).to eq(match_client3)
              expect(response).to render_template('clients/index.json')
            end
          end
        end
      end
      context ' and the current user is an average user' do
        it 'returns the list of clients the user has created' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          5.times { FactoryGirl.create :client, creator: user }
          5.times { FactoryGirl.create :client }

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { all: true }

          expect(response).to be_success
          expect(assigns(:clients)).to_not be_nil
          expect(assigns(:clients).size).to eq(5)
          expect(response).to render_template('clients/index.json')
        end

        context 'when the search param is present' do
          it 'returns a list of clients that match the query' do
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
            not_match_client = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, search: 'AAB' }

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(2)
            expect(response).to render_template('clients/index.json')
          end
        end

        context 'when the order param is present' do
          it 'returns a list of clients ordered by a field name' do
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
            match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, ordered: { lastname: :desc }}

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(3)
            expect(assigns(:clients).first).to eq(match_client3)
            expect(response).to render_template('clients/index.json')
          end


          context 'but is erratic' do
            it 'returns a list of clients ordered by the default' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
              FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
              FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

              match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
              match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
              match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, ordered: { not_a_column: :desc }}

              expect(response).to be_success
              expect(assigns(:clients)).to_not be_nil
              expect(assigns(:clients).size).to eq(3)
              expect(assigns(:clients).first).to eq(match_client1)
              expect(response).to render_template('clients/index.json')
            end
          end
        end

        context 'when the paginated param is present' do
          it 'returns a list of clients with the offset and limit specified' do
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
            FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
            FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

            match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
            match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
            match_client4 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, paginated: { offset: 0, limit: 2 } }

            expect(response).to be_success
            expect(assigns(:clients)).to_not be_nil
            expect(assigns(:clients).size).to eq(2)
            expect(assigns(:clients).first).to eq(match_client1)
            expect(response).to render_template('clients/index.json')
          end

          context 'but the range is erratic' do
            it 'returns what can be returned with that range' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC'
              FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB'
              FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF'

              match_client1 = FactoryGirl.create :client, firstname: 'AAB', lastname: 'BBC', creator: user
              match_client2 = FactoryGirl.create :client, firstname: 'BAA', lastname: 'AAB', creator: user
              match_client3 = FactoryGirl.create :client, firstname: 'ZZA', lastname: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, paginated: { offset: 2, limit: 10 }}

              expect(response).to be_success
              expect(assigns(:clients)).to_not be_nil
              expect(assigns(:clients).size).to eq(1)
              expect(assigns(:clients).first).to eq(match_client3)
              expect(response).to render_template('clients/index.json')
            end
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when the current user has admin rights' do
      context 'and the id is from other user client' do
        it 'returns the client data using the specified id' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_retrieve = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: client_to_retrieve.id }

          expect(response).to be_success
          expect(assigns(:client)).to eq(client_to_retrieve)
          expect(response).to render_template('clients/show.json')
        end
      end
      context 'the id is not from an actual client' do
        it 'returns 404' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: 969 }

          expect(response).to be_not_found
        end
      end
    end
    context 'when the current user is an average user' do
      context 'and the id is from a client the current user does own' do
        it 'returns the client data using the specified id' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_retrieve = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: client_to_retrieve.id }

          expect(response).to be_success
          expect(assigns(:client)).to eq(client_to_retrieve)
          expect(response).to render_template('clients/show.json')
        end
      end
      context 'and the id is from other user client' do
        it 'returns forbidden' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_retrieve = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: client_to_retrieve.id }

          expect(response).to be_forbidden
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when the right client information is present' do
      it 'creates a new client and sets the current user as creator' do
        user = FactoryGirl.create :user, :confirmed, :staff
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :create, params: { client: FactoryGirl.attributes_for(:client) }}.to change{ Client.count }.by(1)
        expect(response).to be_success
        expect(assigns(:client).creator).to eq(user)
      end

      it 'returns a json object with the new client' do
        user = FactoryGirl.create :user, :confirmed, :staff
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { client: FactoryGirl.attributes_for(:client) }
        
        expect(response).to be_success
        expect(response).to render_template('clients/show.json')
      end
    end

    context 'when the client information is erratic' do
      it 'does not create a new client' do
        user = FactoryGirl.create :user, :confirmed, :staff
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :create, params: { client: { firstname: '', lastname: '' }}}.to_not change{ Client.count }
        expect(response).to be_success
      end
      it 'returns the client errors json object' do
        user = FactoryGirl.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { client: { firstname: '', lastname: '' }}

        expect(response.body).to_not be_empty
        expect(assigns(:client).errors).to_not be_empty
      end
    end
  end

  describe 'PATCH #Update' do
    context 'when the current user has admin rights' do
      context 'and the right client information is present' do
        it 'updates the client' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          client_to_update.reload

          expect(client_to_update.firstname).to eq('Bombar')
          expect(client_to_update.lastname).to eq('De Anda') 
          expect(response).to be_success
        end

        it 'returns the updated client' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('clients/show.json')
        end
      end

      context 'and the client information is erratic' do
        it 'does not updates the client' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: '', lastname: '' } }

          previous_firstname = client_to_update.firstname
          client_to_update.reload

          expect(client_to_update.firstname).to eq(previous_firstname)
          expect(response).to be_success
        end

        it 'returns the clients errors json object' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: '', lastname: '' } }

          expect(response.body).to_not be_empty
          expect(assigns(:client).errors).to_not be_empty
        end
      end

      context 'and is changing a client created by other user' do
        it 'updates the client' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryGirl.create :user
          client_to_update = FactoryGirl.create :client, creator: other_user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          client_to_update.reload

          expect(client_to_update.firstname).to eq('Bombar')
          expect(client_to_update.lastname).to eq('De Anda') 
          expect(response).to be_success
        end

        it 'returns the updated client' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('clients/show.json')
        end
      end
    end
    context 'when the current user is an average user' do
      context 'and is changing a client created by the current user (self)' do
        it 'updates the client' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          client_to_update.reload

          expect(client_to_update.firstname).to eq('Bombar')
          expect(client_to_update.lastname).to eq('De Anda') 
          expect(response).to be_success
        end

        it 'returns the updated client' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('clients/show.json')
        end
      end

      context 'and is changing a client created by other user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryGirl.create :user
          client_to_update = FactoryGirl.create :client, creator: other_user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { firstname: 'Bombar', lastname: 'De Anda' } }

          previous_firstname = client_to_update.firstname
          client_to_update.reload

          expect(client_to_update.firstname).to eq(previous_firstname)
          expect(response).to be_forbidden
        end
      end
    end
    context 'when the active param is present' do
      context 'and the current user is admin/staff user' do
        it 'changes the client active state' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { active: false } }

          client_to_update.reload

          expect(client_to_update).to_not be_active
          expect(response).to be_success
        end
      end
      context 'and the current user is an average user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_update = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: client_to_update.id, client: { active: false } }

          client_to_update.reload

          expect(client_to_update).to be_active
          expect(response).to be_forbidden
        end
      end
    end
    context 'the id is not from an actual client' do
      it 'returns 404' do
        user = FactoryGirl.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        patch :update, params: { id: 969 }

        expect(response).to be_not_found
      end
    end
  end
end
