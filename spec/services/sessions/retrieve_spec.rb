require 'rails_helper'

describe Sessions::Retrieve do
  describe '#process' do
    context 'when the right token is present' do
      it 'returs the autheticated' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        service = Sessions::Retrieve.new token: token

        expect(service.process).to eq(user)
      end

      context 'but the token alive time had passed' do
        it 'returs nil' do
          user = FactoryGirl.create :user, :confirmed
          token = Utils::GenerateToken.for data: { user_id: user.id, created_at: (Time.now - Sessions.configuration.session_token_time_alive).to_i }

          service = Sessions::Retrieve.new token: token

          expect(service.process).to be_nil
        end
      end
    end

    context 'when an erratic token is present' do
      it 'returs nil' do
        user = FactoryGirl.create :user
        service = Sessions::Retrieve.new token: 'erratic token'

        expect(service.process).to be_nil
      end
    end
  end
end
