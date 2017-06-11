require 'rails_helper'

RSpec.describe RentsController, type: :controller do
  describe 'GET #index' do
    it 'returns the list of rents the user has created' do
      user = FactoryGirl.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      5.times { FactoryGirl.create :rent, creator: user }
      5.times { FactoryGirl.create :rent }

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :index

      expect(response).to be_success
      expect(assigns(:rents)).to_not be_nil
      expect(assigns(:rents).size).to eq(5)
      expect(response).to render_template('rents/index.json')
    end

    context 'when the search param is present' do
      it 'returns a list of rents that match the query' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { search: 'AAB' }

        expect(response).to be_success
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(2)
        expect(response).to render_template('rents/index.json')
      end
    end

    context 'when the order param is present' do
      it 'returns a list of rents ordered by a field name' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { ordered: { additional_charges_notes: :desc }}

        expect(response).to be_success
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(3)
        expect(assigns(:rents).first).to eq(match_rent3)
        expect(response).to render_template('rents/index.json')
      end


      context 'but is erratic' do
        it 'returns a list of rents ordered by the default' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
          FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
          FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

          match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
          match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
          match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { not_a_column: :desc }}

          expect(response).to be_success
          expect(assigns(:rents)).to_not be_nil
          expect(assigns(:rents).size).to eq(3)
          expect(assigns(:rents).first).to eq(match_rent1)
          expect(response).to render_template('rents/index.json')
        end
      end
    end

    context 'when the paginated param is present' do
      it 'returns a list of clients with the offset and limit specified' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
        FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
        FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

        match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
        match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
        match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index, params: { paginated: { offset: 0, limit: 2 } }

        expect(response).to be_success
        expect(assigns(:rents)).to_not be_nil
        expect(assigns(:rents).size).to eq(2)
        expect(assigns(:rents).first).to eq(match_rent1)
        expect(response).to render_template('rents/index.json')
      end

      context 'but the range is erratic' do
        it 'returns what can be returned with that range' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
          FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
          FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

          match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
          match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
          match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 2, limit: 10 }}

          expect(response).to be_success
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
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          5.times { FactoryGirl.create :rent, creator: user }
          5.times { FactoryGirl.create :rent }

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { all: true }

          expect(response).to be_success
          expect(assigns(:rents)).to_not be_nil
          expect(assigns(:rents).size).to eq(10)
          expect(response).to render_template('rents/index.json')
        end

        context 'when the search param is present' do
          it 'returns a list of rents that match the query' do
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, search: 'AAB' }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(2)
            expect(response).to render_template('rents/index.json')
          end
        end

        context 'when the order param is present' do
          it 'returns a list of rents ordered by a field name' do
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, ordered: { additional_charges_notes: :desc }}

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(3)
            expect(assigns(:rents).first).to eq(match_rent3)
            expect(response).to render_template('rents/index.json')
          end


          context 'but is erratic' do
            it 'returns a list of rents ordered by the default' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, ordered: { not_a_column: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end
          end
        end

        context 'when the paginated param is present' do
          it 'returns a list of clients with the offset and limit specified' do
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
            match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
            match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { all: true, paginated: { offset: 0, limit: 2 } }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(2)
            expect(assigns(:rents).first).to eq(match_rent1)
            expect(response).to render_template('rents/index.json')
          end

          context 'but the range is erratic' do
            it 'returns what can be returned with that range' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC'
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB'
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF'

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { all: true, paginated: { offset: 2, limit: 10 }}

              expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_user = FactoryGirl.create :user

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, creator: specified_user }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: specified_user.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_user = FactoryGirl.create :user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: specified_user.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: specified_user.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_user = FactoryGirl.create :user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: specified_user
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: specified_user
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: specified_user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: specified_user.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_user = FactoryGirl.create :user

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, creator: specified_user }

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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryGirl.create :user

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, creator: other_user }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { user_id: user.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(7)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                other_user = FactoryGirl.create :user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: user.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryGirl.create :user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { user_id: user.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                other_user = FactoryGirl.create :user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: other_user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: other_user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: other_user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { user_id: user.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryGirl.create :user

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, creator: other_user }

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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryGirl.create :client

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryGirl.create :client

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryGirl.create :client

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryGirl.create :client

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_client }

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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryGirl.create :client, creator: user

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_client }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { client_id: specified_client.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client, creator: user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client, creator: user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryGirl.create :client, creator: user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_client = FactoryGirl.create :client, creator: user

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { client_id: specified_client.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_client = FactoryGirl.create :client, creator: user

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_client
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_client
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_client

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { client_id: specified_client.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_client = FactoryGirl.create :client

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_client }

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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryGirl.create :place

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_place.client, place: specified_place }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryGirl.create :place

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryGirl.create :place

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_place = FactoryGirl.create :place

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              specified_place = FactoryGirl.create :place

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed, :admin
                token = Sessions::Create.for credential: user.username, password: user.password

                specified_place = FactoryGirl.create :place

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryGirl.create :place

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_place.client, place: specified_place  }

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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            client = FactoryGirl.create :client, creator: user
            specified_place = FactoryGirl.create :place, client: client

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_place.client, place: specified_place  }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_success
            expect(assigns(:rents)).to_not be_nil
            expect(assigns(:rents).size).to eq(5)
            expect(response).to render_template('rents/index.json')
          end

          context 'when the search param is present' do
            it 'returns a list of rents that match the query' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryGirl.create :client, creator: user
              specified_place = FactoryGirl.create :place, client: client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              not_match_rent = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, search: 'AAB' }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2) 
              expect(response).to render_template('rents/index.json')
            end
          end

          context 'when the order param is present' do
            it 'returns a list of rents ordered by a field name' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryGirl.create :client, creator: user
              specified_place = FactoryGirl.create :place, client: client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, ordered: { additional_charges_notes: :desc }}

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(3)
              expect(assigns(:rents).first).to eq(match_rent3)
              expect(response).to render_template('rents/index.json')
            end


            context 'but is erratic' do
              it 'returns a list of rents ordered by the default' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                client = FactoryGirl.create :client, creator: user
                specified_place = FactoryGirl.create :place, client: client

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, ordered: { not_a_column: :desc }}

                expect(response).to be_success
                expect(assigns(:rents)).to_not be_nil
                expect(assigns(:rents).size).to eq(3)
                expect(assigns(:rents).first).to eq(match_rent1)
                expect(response).to render_template('rents/index.json')
              end
            end
          end

          context 'when the paginated param is present' do
            it 'returns a list of clients with the offset and limit specified' do
              user = FactoryGirl.create :user, :confirmed
              token = Sessions::Create.for credential: user.username, password: user.password

              client = FactoryGirl.create :client, creator: user
              specified_place = FactoryGirl.create :place, client: client

              FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
              FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
              FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

              match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
              match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
              match_rent4 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

              request.headers[:HTTP_AUTH_TOKEN] = token
              get :index, params: { place_id: specified_place.id, paginated: { offset: 0, limit: 2 } }

              expect(response).to be_success
              expect(assigns(:rents)).to_not be_nil
              expect(assigns(:rents).size).to eq(2)
              expect(assigns(:rents).first).to eq(match_rent1)
              expect(response).to render_template('rents/index.json')
            end

            context 'but the range is erratic' do
              it 'returns what can be returned with that range' do
                user = FactoryGirl.create :user, :confirmed
                token = Sessions::Create.for credential: user.username, password: user.password

                client = FactoryGirl.create :client, creator: user
                specified_place = FactoryGirl.create :place, client: client

                FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', creator: user
                FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', creator: user
                FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', creator: user

                match_rent1 = FactoryGirl.create :rent, product: 'AAB', additional_charges_notes: 'BBC', client: specified_place.client, place: specified_place 
                match_rent2 = FactoryGirl.create :rent, product: 'BAA', additional_charges_notes: 'AAB', client: specified_place.client, place: specified_place 
                match_rent3 = FactoryGirl.create :rent, product: 'ZZA', additional_charges_notes: 'XXF', client: specified_place.client, place: specified_place 

                request.headers[:HTTP_AUTH_TOKEN] = token
                get :index, params: { place_id: specified_place.id, paginated: { offset: 2, limit: 10 }}

                expect(response).to be_success
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
            user = FactoryGirl.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            specified_place = FactoryGirl.create :place

            7.times { FactoryGirl.create :rent, creator: user }
            5.times { FactoryGirl.create :rent, client: specified_place.client, place: specified_place  }

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { place_id: specified_place.id }

            expect(response).to be_forbidden
          end
        end
      end
    end
  end


end
