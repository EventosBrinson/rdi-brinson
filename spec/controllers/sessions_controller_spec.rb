require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before { ActionMailer::Base.deliveries = [] }

  describe 'POST #register' do
    context 'when the right credentials are present' do
      it 'register a new user into the system and send the invitation email' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :register, params: { user: { email: 'omarandstuff@gmail.com', username: 'omarandstuff', firstname: 'David', lastname: 'De Anda', role: 'admin' }}}.to change{ User.count }.by(1)
        expect(response).to be_success
        expect(assigns(:user)).to_not be_confirmed
        expect(ActionMailer::Base.deliveries).to_not be_empty
      end

      it 'returns a json object with the new user' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :register, params: { user: { email: 'omarandstuff@gmail.com', username: 'omarandstuff', firstname: 'David', lastname: 'De Anda', role: 'admin' }}

        expect(response).to be_success
        expect(response).to render_template('users/show.json')
      end
    end

    context 'when the credentials are erratic' do
      it 'does not create a new user' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token

        expect{ post :register, params: { user: { email: 'erratic_email', username: '', password: '' }}}.to_not change{ User.count }
        expect(response).to_not be_success
      end

      it 'returns empty and unsuccessfull' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        post :register, params: { user: { email: 'erratic_email', username: '', password: '' }}

        expect(response).to_not be_success
      end
    end
  end

  describe 'POST #sign_in' do
    context 'when a session token is present' do
      context 'and is a well formated token' do
        it 'returns a json object with the user data and the new session token' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :sign_in

          expect(response).to be_success
          expect(assigns(:user)).to eq user
          expect(response).to render_template('sessions/show.json')
        end
      end

      context 'and is an erratic token' do
        it 'returns empty and false' do
          user = FactoryGirl.create :user, :confirmed
          token = 'erratic token'

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :sign_in

          expect(response).to be_success
          expect(response.body).to eq 'false'
        end
      end
    end

    context 'when credentials are present' do
      context 'and are the right ones' do
        it 'returns a json object with the user data and a session token' do
          user = FactoryGirl.create :user, :confirmed

          post :sign_in, params: { credential: user.email, password: user.password }

          expect(response).to be_success
          expect(response).to render_template('sessions/show.json')
        end

        context 'but the user is still pending for confirmation' do
          it 'returns empty and false' do
            user = FactoryGirl.create :user

            post :sign_in, params: { credential: user.email, password: user.password }

            expect(response).to be_success
            expect(response.body).to eq 'false'
          end
        end
      end

      context 'and are the wrong ones' do
        it 'returns empty and false' do
          user = FactoryGirl.create :user

          post :sign_in, params: { credential: 'wrong_credential', password: 'wrong_password' }

          expect(response).to be_success
          expect(response.body).to eq 'false'
        end
      end
    end
  end

  describe 'DELETE #sign_out' do
    context 'when the right session token is present' do
      it 'returns empty and successfull' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        delete :sign_out

        expect(response).to be_success
        expect(response.body).to be_empty
      end
    end

    context 'when an erratic session token is present' do
      it 'returns empty, unsuccessfull and nothing else happens' do
        user = FactoryGirl.create :user
        token = 'erratic token'

        request.headers[:HTTP_AUTH_TOKEN] = token
        delete :sign_out

        expect(response).to_not be_success
      end
    end
  end

  describe 'PATCH #confirm' do
    context 'when a valid confirmation token and new password are present' do
      it 'returns empty, successfull, confirm the user and sent a confirmation email' do
        user = FactoryGirl.create :user, :confirmation_open

        patch :confirm, params: { token: user.confirmation_token, password: 'supersecret' }

        expect(response).to be_success
        expect(assigns(:user)).to be_confirmed
        expect(assigns(:user).password).to eq 'supersecret'
        expect(ActionMailer::Base.deliveries).to_not be_empty
      end
    end

    context 'when an erratic confirmation token is present' do
      it 'returns empty and unsuccessfull' do
        user = FactoryGirl.create :user, password: nil

        patch :confirm, params: { token: 'erratic_confirmation_token', password: 'supersecret' }

        expect(response).to_not be_success
        expect(assigns(:user)).to be_nil
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe 'POST #request_reset_password' do
    context 'when the right credential is preset' do
      it 'returns empty, successfull, set user reset_password attributes and send the reset password email' do
        user = FactoryGirl.create :user, :confirmed

        expect{ post(:request_reset_password, params: { credential: user.username }) }.to change{ User.first.reset_password_requested? }.to(true)
        expect(response).to be_success
        expect(ActionMailer::Base.deliveries).to_not be_empty
      end
    end

    context 'when the credential of an unconfirmed user is present' do
      it 'returns empty, successfull and nothing else happen' do
        user = FactoryGirl.create :user, :confirmation_open

        expect{ post(:request_reset_password, params: { credential: user.username }) }.to_not change{ User.first.reset_password_requested? }
        expect(response).to be_success
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'when an erratic credential is present' do
      it 'returns empty, successfull and nothing else happen' do
        user = FactoryGirl.create :user, :confirmed

        expect{ post(:request_reset_password, params: { credential: 'erratic_credential' }) }.to_not change{ User.first.reset_password_requested? }
        expect(response).to be_success

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe 'PATCH #reset_password' do
    context 'when the right reset password token is present' do
      context 'and a valid password is present' do
        it 'returns empty, successfull, changes the user password and send the password changed email' do
          user = FactoryGirl.create :user, :reset_password_requested

          expect{ post(:reset_password, params: { token: user.reset_password_token, password: 'new_password' }) }.to change{ User.first.password_digest }
          expect(response).to be_success
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end
      end

      context 'and an erratic password is present' do
        it 'returns empty, unsuccessfull and nothing else happen' do
          user = FactoryGirl.create :user, :reset_password_requested

          expect{ post(:reset_password, params: { token: user.reset_password_token, password: '' }) }.to_not change{ User.first.password_digest }
          expect(response).to_not be_success
        end
      end
    end

    context 'when an erratic reset password token is present' do
      it 'returns empty, unsuccessfull and nothing else happen' do
        user = FactoryGirl.create :user, :reset_password_requested

        expect{ post(:reset_password, params: { token: 'erratic_reset_password_token', password: 'irrelevant_password' }) }.to_not change{ User.first.password_digest }
        expect(response).to_not be_success
      end
    end
  end
end
