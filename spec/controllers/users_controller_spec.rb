require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { ActionMailer::Base.deliveries = [] }

  describe 'GET #Index' do
    context 'when current user has admin rights' do
      it 'returns the lists of users' do
        user = FactoryBot.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        5.times { FactoryBot.create :user }

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index

        expect(response).to be_successful
        expect(assigns(:users)).to_not be_nil
        expect(assigns(:users).size).to eq(6)
        expect(response).to render_template('users/index.json')
      end

      context 'when the search param is present' do
        it 'returns a list of users that match the query' do
          user = FactoryBot.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          match_user1 = FactoryBot.create :user, firstname: 'AAB', lastname: 'BBC'
          match_user2 = FactoryBot.create :user, firstname: 'BAA', lastname: 'AAB'
          not_match_user = FactoryBot.create :user, firstname: 'ZZA', lastname: 'XXF'

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { search: 'AAB' }

          expect(response).to be_successful
          expect(assigns(:users)).to_not be_nil
          expect(assigns(:users).size).to eq(2)
          expect(response).to render_template('users/index.json')
        end
      end

      context 'when the order param is present' do
        it 'returns a list of users ordered by a field name' do
          user = FactoryBot.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          match_user1 = FactoryBot.create :user, firstname: 'AAB', lastname: 'BBC'
          match_user2 = FactoryBot.create :user, firstname: 'BAA', lastname: 'AAB'
          match_user3 = FactoryBot.create :user, firstname: 'ZZA', lastname: 'XXF'

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { ordered: { lastname: :desc }}

          expect(response).to be_successful
          expect(assigns(:users)).to_not be_nil
          expect(assigns(:users).size).to eq(4)
          expect(assigns(:users).first).to eq(match_user3)
          expect(response).to render_template('users/index.json')
        end

        context 'but is erratic' do
          it 'returns a list of users ordered by the default' do
            user = FactoryBot.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            match_user1 = FactoryBot.create :user, firstname: 'AAB', lastname: 'BBC'
            match_user2 = FactoryBot.create :user, firstname: 'BAA', lastname: 'AAB'
            match_user3 = FactoryBot.create :user, firstname: 'ZZA', lastname: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { ordered: { not_a_column: :desc }}

            expect(response).to be_successful
            expect(assigns(:users)).to_not be_nil
            expect(assigns(:users).size).to eq(4)
            expect(assigns(:users).first).to eq(user)
            expect(response).to render_template('users/index.json')
          end
        end
      end
      context 'when the paginated param is present' do
        it 'returns a list of users with the offset and limit specified' do
          user = FactoryBot.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          match_user1 = FactoryBot.create :user, firstname: 'AAB', lastname: 'BBC'
          match_user2 = FactoryBot.create :user, firstname: 'BAA', lastname: 'AAB'
          match_user3 = FactoryBot.create :user, firstname: 'ZZA', lastname: 'XXF'

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :index, params: { paginated: { offset: 0, limit: 2 } }

          expect(response).to be_successful
          expect(assigns(:users)).to_not be_nil
          expect(assigns(:users).size).to eq(2)
          expect(assigns(:users).first).to eq(user)
          expect(response).to render_template('users/index.json')
        end

        context 'but the range is erratic' do
          it 'returns what can be returned with that range' do
            user = FactoryBot.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            match_user1 = FactoryBot.create :user, firstname: 'AAB', lastname: 'BBC'
            match_user2 = FactoryBot.create :user, firstname: 'BAA', lastname: 'AAB'
            match_user3 = FactoryBot.create :user, firstname: 'ZZA', lastname: 'XXF'

            request.headers[:HTTP_AUTH_TOKEN] = token
            get :index, params: { paginated: { offset: 2, limit: 10 }}

            expect(response).to be_successful
            expect(assigns(:users)).to_not be_nil
            expect(assigns(:users).size).to eq(2)
            expect(assigns(:users).first).to eq(match_user2)
            expect(response).to render_template('users/index.json')
          end
        end
      end
    end

    context 'when the current user does not has admin rights' do
      it 'returns forbidden' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        5.times { FactoryBot.create :user }

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index

        expect(response).to be_forbidden
      end
    end
  end

  describe 'GET #show' do
    context 'when the current user has admin rights' do
      it 'returns the user data using the specified id' do
        user = FactoryBot.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        user_to_retreave = FactoryBot.create(:user)

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :show, params: { id: user_to_retreave.id }

        expect(response).to be_successful
        expect(assigns(:user)).to eq(user_to_retreave)
        expect(response).to render_template('users/show.json')
      end

      context 'the id is not from an actual user' do
        it 'returns 404' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: user.id + 1 }

          expect(response).to be_not_found
        end
      end
    end

    context 'when the current user has not admin rights' do
      context 'and the id is from the same user' do
        it 'returns the user data using the specified id' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          user_to_retreave = user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: user_to_retreave.id }

          expect(response).to be_successful
          expect(assigns(:user)).to eq(user_to_retreave)
          expect(response).to render_template('users/show.json')
        end
      end

      context 'and the id is from other user' do
        it 'returns forbiden' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          user_to_retreave = FactoryBot.create :user

          request.headers[:HTTP_AUTH_TOKEN] = token
          get :show, params: { id: user_to_retreave.id }

          expect(response).to be_forbidden
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when current user has admin rights' do
      context 'and a role under admin/staff is present' do
        context 'and the right user information is present' do
          it 'creates a new user sends the invitation email' do
            user = FactoryBot.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token

            expect{ post :create, params: { user: FactoryBot.attributes_for(:user) }}.to change{ User.count }.by(1)
            expect(response).to be_successful
            expect(assigns(:user)).to_not be_confirmed
            expect(ActionMailer::Base.deliveries).to_not be_empty
          end

          it 'returns a json object with the new user' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token
            post :create, params: { user: FactoryBot.attributes_for(:user) }

            expect(response).to be_successful
            expect(response).to render_template('users/show.json')
          end
        end

        context 'when the user information is erratic' do
          it 'does not create a new user' do
            user = FactoryBot.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token

            expect{ post :create, params: { user: { email: 'erratic_email', username: '', password: '' }}}.to_not change{ User.count }
            expect(response).to be_successful
          end
          it 'returns the user errors json object' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token
            post :create, params: { user: { email: 'erratic_email', username: '', password: '' }}

            expect(response.body).to_not be_empty
          end
        end

        context 'and an admin/staff role is present' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed, :staff
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token

            expect{ post :create, params: { user: FactoryBot.attributes_for(:user, :admin) }}.to_not change{ User.count }
            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'when current user is a main user' do
      context 'and an admin/staff role is present' do
        it 'creates a new user sends the invitation email' do
          user = FactoryBot.create :user, :confirmed, :staff, :main
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token

          expect{ post :create, params: { user: FactoryBot.attributes_for(:user, :admin) }}.to change{ User.count }.by(1)
          expect(response).to be_successful
          expect(assigns(:user)).to_not be_confirmed
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end

        it 'returns a json object with the new user' do
          user = FactoryBot.create :user, :confirmed, :admin, :main
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :create, params: { user: FactoryBot.attributes_for(:user) }

          expect(response).to be_successful
          expect(response).to render_template('users/show.json')
        end
      end
    end

    context 'when current user does not has admin rights nor is a main user' do
      it 'returns forbiden and nothing else happens' do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :create, params: { user: FactoryBot.attributes_for(:user) }}.to_not change{ User.count }
        expect(response).to be_forbidden
      end
    end
  end

  describe 'PATCH #Update' do
    context 'when the current user is changing its own information' do
      context 'and the right information is present' do
        it 'updates the user editable fields' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          user.reload

          expect(user.firstname).to eq('Bombar')
          expect(user.lastname).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated user json object' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('users/show.json')
        end
      end
      context 'and erratic information is present' do
        it 'does not update the user' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { firstname: '', lastname: '' } }

          previous_firstname = user.firstname
          user.reload

          expect(user.firstname).to eq(previous_firstname)
          expect(response).to be_successful
        end

        it 'returns the user errors json object' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { firstname: '', lastname: '' } }

          expect(response.body).to_not be_empty
        end
      end
    end

    context 'when the current user is changing an average user information' do
      context 'and the current user is an admin/staff user' do
        it 'changes the other user editable fields' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          other_user.reload

          expect(other_user.firstname).to eq('Bombar')
          expect(other_user.lastname).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated user json object' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('users/show.json')
        end
      end
      context 'and the current user is an average user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          previous_firstname = other_user.firstname
          other_user.reload

          expect(other_user.firstname).to eq(previous_firstname)
          expect(response).to be_forbidden
        end
      end
    end

    context 'when the current user is changing an admin/staff user information' do
      context 'and the current user is a main user' do
        it 'changes the other user editable fields' do
          user = FactoryBot.create :user, :confirmed, :admin, :main
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user, :admin

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          other_user.reload

          expect(other_user.firstname).to eq('Bombar')
          expect(other_user.lastname).to eq('De Anda') 
          expect(response).to be_successful
        end

        it 'returns the updated user json object' do
          user = FactoryBot.create :user, :confirmed, :admin, :main
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user, :admin

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          expect(response).to render_template('users/show.json')
        end
      end
      context 'and the current user is not a main user' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          other_user = FactoryBot.create :user, :admin

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: other_user.id, user: { firstname: 'Bombar', lastname: 'De Anda' } }

          previous_firstname = other_user.firstname
          other_user.reload

          expect(other_user.firstname).to eq(previous_firstname)
          expect(response).to be_forbidden
        end
      end
    end

    context 'when email param is present' do
      context 'and the current user is changing its own email' do
        it 'changes the current user email, opens a confirmation and sends the reconfirmation email' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { email: 'correo@plati.volos' } }

          user.reload

          expect(response).to be_successful
          expect(user.email).to eq('correo@plati.volos')
          expect(assigns(:user)).to_not be_confirmed
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end

        it 'returns the updated user json object' do
          user = FactoryBot.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { email: 'correo@plati.volos' } }

          expect(response).to render_template('users/show.json')
        end
      end
      context 'and the current user is changing an average user email' do
        context 'and the current user is admin/staff user' do
          it 'changes the other user email, opens a confirmation and sends the reconfirmation email' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            other_user.reload

            expect(response).to be_successful
            expect(other_user.email).to eq('correo@plati.volos')
            expect(assigns(:user)).to_not be_confirmed
            expect(ActionMailer::Base.deliveries).to_not be_empty
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            expect(response).to be_forbidden
          end
        end
      end
      context 'and the current user is changing an admin/staff user email' do
        context 'and the current user is a main user' do
          it 'changes the other user email, opens a confirmation and sends the reconfirmation email' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            other_user.reload

            expect(response).to be_successful
            expect(other_user.email).to eq('correo@plati.volos')
            expect(assigns(:user)).to_not be_confirmed
            expect(ActionMailer::Base.deliveries).to_not be_empty
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is not a main user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { email: 'correo@plati.volos' } }

            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'the role param is present' do
      context 'and the current user is changing its own role' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { role: :staff } }

          previous_role = user.role
          user.reload

          expect(user.role).to eq(previous_role)
          expect(response).to be_forbidden
        end
      end
      context 'and the current user is changing an average user role' do
        context 'and the current user is admin/staff user' do
          context 'and the new role is under admin/staff' do
            it 'changes the other user role' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryBot.create :user

              request.headers[:HTTP_AUTH_TOKEN] = token
              patch :update, params: { id: other_user.id, user: { role: :user } }

              other_user.reload

              expect(response).to be_successful
              expect(other_user).to be_user
            end

            it 'returns the updated user json object' do
              user = FactoryBot.create :user, :confirmed, :admin
              token = Sessions::Create.for credential: user.username, password: user.password

              other_user = FactoryBot.create :user

              request.headers[:HTTP_AUTH_TOKEN] = token
              patch :update, params: { id: other_user.id, user: { role: :user } }

              expect(response).to render_template('users/show.json')
            end
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { role: :user } }

            previous_role = other_user.role
            other_user.reload

            expect(other_user.role).to eq(previous_role)
            expect(response).to be_forbidden
          end
        end
      end
      context 'and the current user is changing an admin/staff user role' do
        context 'and the current user is a main user' do
          it 'changes the other user role' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { role: :user } }

            other_user.reload

            expect(response).to be_successful
            expect(other_user).to be_user
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { role: :user } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is not a main user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { role: :user } }

            previous_role = other_user.role
            other_user.reload

            expect(other_user.role).to eq(previous_role)
            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'the password param is present' do
      context 'and the current user is changing its own password' do
        context 'and the right current password is present' do
          it 'changes the current user password and sends the password changed email' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: user.id, user: { password: 'supersecret_password' } }

            expect(response).to be_successful
            expect(assigns(:user).password).to eq('supersecret_password')
            expect(ActionMailer::Base.deliveries).to_not be_empty
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: user.id, user: { password: 'supersecret_password' } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the wrong current password is present' do
          it 'returns the user errors json object' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: user.id, user: { password: '' } }

            expect(response).to be_successful
            expect(response.body).to_not be_empty
            expect(assigns(:user).errors).to_not be_empty
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end
      end
      context 'and the current user is changing an average user password' do
        context 'and the current user is admin/staff user' do
          it 'changes the other user password and sends the password changed email' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to be_successful
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to be_forbidden
          end
        end
      end
      context 'and the current user is changing an an admin/staff user password' do
        context 'and the current user is a main user' do
          it 'changes the other user password and sends the password changed email' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to be_successful
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is not main user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :confirmed, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { password: 'supersecret_password' } }

            expect(response).to be_forbidden
          end
        end
      end
    end

  context 'the active param is present' do
      context 'and the current user is changing its own active attribute' do
        it 'returns forbiden and nothing else happens' do
          user = FactoryBot.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: user.id, user: { active: :false } }

          previous_active = user.active
          user.reload

          expect(user.active).to eq(previous_active)
          expect(response).to be_forbidden
        end
      end
      context 'and the current user is changing an average user active' do
        context 'and the current user is admin/staff user' do
          it 'changes the other user active attribute' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            other_user.reload

            expect(response).to be_successful
            expect(other_user).to_not be_active
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            previous_active = other_user.active
            other_user.reload

            expect(other_user.active).to eq(previous_active)
            expect(response).to be_forbidden
          end
        end
      end
      context 'and the current user is changing an admin/staff user active' do
        context 'and the current user is a main user' do
          it 'changes the other user active attribute' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            other_user.reload

            expect(response).to be_successful
            expect(other_user).to_not be_active
          end

          it 'returns the updated user json object' do
            user = FactoryBot.create :user, :confirmed, :admin, :main
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            expect(response).to render_template('users/show.json')
          end
        end
        context 'and the current user is not a main user' do
          it 'returns forbiden and nothing else happens' do
            user = FactoryBot.create :user, :confirmed, :admin
            token = Sessions::Create.for credential: user.username, password: user.password

            other_user = FactoryBot.create :user, :admin

            request.headers[:HTTP_AUTH_TOKEN] = token
            patch :update, params: { id: other_user.id, user: { active: :false } }

            previous_active = other_user.active
            other_user.reload

            expect(other_user.active).to eq(previous_active)
            expect(response).to be_forbidden
          end
        end
      end
    end

    context 'when the id is not from an actual user' do
      it 'returns 404' do
        user = FactoryBot.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        patch :update, params: { id: user.id + 1 }

        expect(response).to be_not_found
      end
    end
  end
end
