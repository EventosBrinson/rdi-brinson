require 'rails_helper'

RSpec.describe RentsController, type: :controller do
  describe 'GET #index' do
    it 'returns the list of rents the user has created' do
      user = FactoryBot.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      5.times { FactoryBot.create :rent, creator: user }
      5.times { FactoryBot.create :rent }

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :index

      expect(response).to be_successful
      expect(assigns(:rents)).to_not be_nil
      expect(assigns(:rents).size).to eq(5)
      expect(response).to render_template('rents/index.json')
    end

    context 'when the search param is present' do
      it 'returns a list of rents that match the query' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { search: 'AAB' }

        expect(response).to be_successful
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(2)
        expect(response).to render_template('rents/index.json')
      end
    end

    context 'when the order param is present' do
      it 'returns a list of rents ordered by a field name' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { ordered: { additional_charges_notes: :desc }}

        expect(response).to be_successful
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(3)
        expect(assigns(:rents).first).to eq(match_rent3)
        expect(response).to render_template('rents/index.json')
      end


      context 'but is erratic' do
        it 'returns a list of rents ordered by the default' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
          FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
          FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

          match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
          match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
          match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { not_a_column: :desc }}

          expect(response).to be_successful
          expect(assigns(:rents)).to_not be_nil
          expect(assigns(:rents).size).to eq(3)
          expect(assigns(:rents).first).to eq(match_rent1)
          expect(response).to render_template('rents/index.json')
        end
      end
    end

    context 'when the paginated param is present' do
      it 'returns a list of clients with the offset and limit specified' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { paginated: { offset: 0, limit: 2 } }

        expect(response).to be_successful
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(2)
        expect(assigns(:rents).first).to eq(match_rent1)
        expect(response).to render_template('rents/index.json')
      end

      context 'but the range is erratic' do
        it 'returns what can be returned with that range' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
          FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
          FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

          match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
          match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
          match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 2, limit: 10 }}

          expect(response).to be_successful
          expect(assigns(:rents)).to_not be_nil
          expect(assigns(:rents).size).to eq(1)
          expect(assigns(:rents).first).to eq(match_rent3)
          expect(response).to render_template('rents/index.json')
        end
      end
    end

    context 'and the "all" param is present' do
      context ' and the current user has admin rights' do
        it 'returns the list of all rents' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          5.times { FactoryBot.create :rent, creator: user }
          5.times { FactoryBot.create :rent }

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { all: true }

          expect(response).to be_successful
          expect(assigns(:rents)).to_not be_nil
          expect(assigns(:rents).size).to eq(10)
          expect(response).to render_template('rents/index.json')
        end

        context 'when the search param is present' do
          it 'returns a list of rents that match the query' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, search: 'AAB' }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(2)
            expect(response).to render_template('rents/index.json')
          end
        end

        context 'when the order param is present' do
          it 'returns a list of rents ordered by a field name' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, ordered: { additional_charges_notes: :desc }}

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(3)
            expect(assigns(:rents).first).to eq(match_rent3)
            expect(response).to render_template('rents/index.json')
          end


          context 'but is erratic' do
            it 'returns a list of rents ordered by the default' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, ordered: { not_a_column: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end
          end
        end

        context 'when the paginated param is present' do
          it 'returns a list of clients with the offset and limit specified' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, paginated: { offset: 0, limit: 2 } }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(2)
            expect(assigns(:rents).first).to eq(match_rent1)
            expect(response).to render_template('rents/index.json')
          end

          context 'but the range is erratic' do
            it 'returns what can be returned with that range' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, paginated: { offset: 2, limit: 10 }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(1)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end
          end
        end
      end
    end

    context 'and the user_id param is present' do
      context 'and the current user has admin rights' do
        context 'and the id is from other user' do
          it 'returns the list of rents that belongs to the specified user' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_user = FactoryBot.create :user

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, creator: specified_user }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: specified_user.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_user = FactoryBot.create :user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: specified_user.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_user = FactoryBot.create :user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: specified_user.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that does not exist' do
          it 'returns not found' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_user = FactoryBot.create :user

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, creator: specified_user }

            safe_id = Rent.pluck(:id).reduce(0){ |sum, x| sum + x }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: safe_id }

            expect(response).to be_not_found
          end
        end
      end
      context 'and the current user is an average user' do
        context 'and the id is from the same user' do
          it 'returns the list of rents that belongs to the specified client' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, creator: other_user }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: user.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(7)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                other_user = FactoryBot.create :user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: user.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryBot.create :user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                other_user = FactoryBot.create :user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: user.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from other user' do
          it 'returns forbidden' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, creator: other_user }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: other_user.id }

            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'and the client_id param is present' do
      context 'and the current user has admin rights' do
        context 'and the id is from a client the current user does not own' do
          it 'returns the list of rents that belongs to the specified client' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryBot.create :client

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryBot.create :client

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that does not exist' do
          it 'returns not found' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_client }

            safe_id = Rent.pluck(:id).reduce(0){ |sum, x| sum + x }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: safe_id }

            expect(response).to be_not_found
          end
        end
      end
      context 'and the current user is and average user' do
        context 'and the id is from a client the current user does own' do
          it 'returns the list of rents that belongs to the specified client' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryBot.create :client, creator: user

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryBot.create :client, creator: user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryBot.create :client, creator: user

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryBot.create :client, creator: user

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that the current user dows not own' do
          it 'returns forbidden' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryBot.create :client

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'and the place_id param is present' do
      context 'and the current user has admin rights' do
        context 'and the id is from a place the current user does not own' do
          it 'returns the list of rents that belongs to the specified place' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryBot.create :place

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_place.client, place: specified_place }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryBot.create :place

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryBot.create :place

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_place = FactoryBot.create :place

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryBot.create :place

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_place = FactoryBot.create :place

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from a client that does not exist' do
          it 'returns not found' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryBot.create :place

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_place.client, place: specified_place  }

            safe_id = Rent.pluck(:id).reduce(0){ |sum, x| sum + x }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: safe_id }

            expect(response).to be_not_found
          end
        end
      end
      context 'and the current user is and average user' do
        context 'and the id is from a place the current user does own' do
          it 'returns the list of rents that belongs to the specified place' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            client = FactoryBot.create :client, creator: user
            specified_place = FactoryBot.create :place, client: client

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_place.client, place: specified_place  }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_successful
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryBot.create :client, creator: user
              specified_place = FactoryBot.create :place, client: client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              not_match_rent = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, search: 'AAB' }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryBot.create :client, creator: user
              specified_place = FactoryBot.create :place, client: client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                client = FactoryBot.create :client, creator: user
                specified_place = FactoryBot.create :place, client: client

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, ordered: { not_a_column: :desc }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryBot.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryBot.create :client, creator: user
              specified_place = FactoryBot.create :place, client: client

              FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent4 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_successful
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryBot.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                client = FactoryBot.create :client, creator: user
                specified_place = FactoryBot.create :place, client: client

                FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryBot.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryBot.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryBot.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_successful
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(1)
                expect(assigns(:rents).first).to eq(match_rent3)
                expect(response).to render_template('rents/index.json')
              end
            end
          end
        end
        context 'and the id is from a place that the current user dows not own' do
          it 'returns forbidden' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryBot.create :place

            7.times { FactoryBot.create :rent, creator: user }
            5.times { FactoryBot.create :rent, client: specified_place.client, place: specified_place  }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_forbidden
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when the current user has admin rights' do
      context 'and the id is from other user rent' do
        it 'returns the rent data using the specified id' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_retrieve = FactoryBot.create :rent

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: rent_to_retrieve.id }

          expect(response).to be_successful
          expect(assigns(:rent)).to eq(rent_to_retrieve)
          expect(response).to render_template('rents/show.json')
        end
      end
      context 'the id is not from an actual rent' do
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
      context 'and the id is from a rent the current user does own' do
        it 'returns the rent data using the specified id' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_retrieve = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: rent_to_retrieve.id }

          expect(response).to be_successful
          expect(assigns(:rent)).to eq(rent_to_retrieve)
          expect(response).to render_template('rents/show.json')
        end
      end
      context 'and the id is from other user rent' do
        it 'returns forbidden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_retrieve = FactoryBot.create :rent

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: rent_to_retrieve.id }

          expect(response).to be_forbidden
        end
      end
    end
    context 'when the pdf extesion is present' do
      it 'sends a pdf file' do
        user = FactoryBot.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        rent_to_retrieve = FactoryBot.create :rent

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :show, params: { id: rent_to_retrieve.id, format: 'pdf' }

        expect(response).to be_successful
        expect(assigns(:rent)).to eq(rent_to_retrieve)
        expect(response.headers['Content-Type']).to eq('application/pdf')
        expect(response.headers['Content-Disposition']).to eq("inline; filename=\"renta_##{rent_to_retrieve.order_number}_#{rent_to_retrieve.client.firstname.parameterize.underscore}.pdf\"")
      end
    end
  end

  describe 'POST #create' do
    context 'when the right rent information is present' do
      it 'creates a new rent' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        target_client = FactoryBot.create :client, creator: user
        targte_place = FactoryBot.create :place, client: target_client

        request.headers[:HTTP_AUTH_TOKEN] = token
        expect{ post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }}.to change{ Rent.count }.by(1)
        expect(response).to be_successful
      end

      it 'returns a json object with the new rent' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        target_client = FactoryBot.create :client, creator: user
        targte_place = FactoryBot.create :place, client: target_client

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }
        
        expect(response).to be_successful
        expect(response).to render_template('rents/show.json')
      end
    end

    context 'when the rent information is erratic' do
      it 'does not create a new rent' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :create, params: { rent: { product: '', price: '' }}}.to_not change{ Rent.count }
        expect(response).to be_successful
      end
      it 'returns the rent errors json object' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :create, params: { rent: { product: '', price: '' }}

        expect(response.body).to_not be_empty
        expect(assigns(:rent).errors).to_not be_empty
      end
    end

    context 'when the current user has admin rights' do
      context 'and the client id is from a client the user does not own' do
        it 'creates a new rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client
          targte_place = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }}.to change{ Rent.count }.by(1)
          expect(response).to be_successful
          expect(response).to render_template('rents/show.json')
        end
      end
      context 'and the place is from a client the user does not own' do
        it 'creates a new rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          targte_place = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }}.to change{ Rent.count }.by(1)
          expect(response).to be_successful
          expect(response).to render_template('rents/show.json')
        end
      end
    end

    context 'when the current user is an average user' do
      context 'and the client id is from a client the user does not own' do
        it 'returns forbidden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client
          targte_place = FactoryBot.create :place, client: target_client

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }}.to_not change{ Place }
          expect(response).to be_forbidden
        end
      end
      context 'and the palce is from a client the user does not own' do
        it 'returns forbidden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          target_client = FactoryBot.create :client, creator: user
          targte_place = FactoryBot.create :place

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ post :create, params: { rent: FactoryBot.attributes_for(:rent).merge({ client_id: target_client.id, place_id: targte_place.id }) }}.to_not change{ Place }
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe 'PATCH #Update' do
    context 'when the current user has admin rights' do
      context 'and the right rent information is present' do
        it 'updates the rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          rent_to_update.reload

          expect(rent_to_update.product).to eq('Bombar')
          expect(rent_to_update.additional_charges_notes).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          expect(response).to render_template('rents/show.json')
        end
      end

      context 'and the rent information is erratic' do
        it 'does not updates the rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: '', additional_charges_notes: '' } }

          previous_product = rent_to_update.product
          rent_to_update.reload

          expect(rent_to_update.product).to eq(previous_product)
          expect(response).to be_successful
        end

        it 'returns the rents errors json object' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: '', additional_charges_notes: '' } }

          expect(response.body).to_not be_empty
          expect(assigns(:rent).errors).to_not be_empty
        end
      end

      context 'and is changing a rent created by other user' do
        it 'updates the rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          rent_to_update.reload

          expect(rent_to_update.product).to eq('Bombar')
          expect(rent_to_update.additional_charges_notes).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated rent' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          expect(response).to render_template('rents/show.json')
        end
      end
    end
    context 'when the current user is an average user' do
      context 'and is changing a rent created by the current user (self)' do
        it 'updates the rent' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          rent_to_update.reload

          expect(rent_to_update.product).to eq('Bombar')
          expect(rent_to_update.additional_charges_notes).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated rent' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          expect(response).to render_template('rents/show.json')
        end
      end

      context 'and is changing a rent created by other user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          previous_product = rent_to_update.product
          rent_to_update.reload

          expect(rent_to_update.product).to eq(previous_product)
          expect(response).to be_forbidden
        end
      end

      context 'and is changing a rent with status diferent than reserved' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          rent_to_update = FactoryBot.create :rent, :on_route, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: rent_to_update.id, rent: { product: 'Bombar', additional_charges_notes: 'De Anda' } }

          previous_product = rent_to_update.product
          rent_to_update.reload

          expect(rent_to_update.product).to eq(previous_product)
          expect(response).to be_forbidden
        end
      end
    end
    context 'the id is not from an actual rent' do
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
