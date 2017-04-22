require 'rails_helper'

describe Sessions::Create do
  describe '#process' do
    context 'when the right credentials are present' do
      it 'returs a new :user, :token hash' do
        user = FactoryGirl.create :user, :confirmed
        service = Sessions::Create.new credential: user.email, password: user.password

        expect(service.process).to include(:user, :token)
      end

      it 'returns a token that, when deserialized contains the user id' do
        user = FactoryGirl.create :user, :confirmed
        service = Sessions::Create.new credential: user.email, password: user.password
        user_and_token = service.process

        token_deserialized = Utils::DeserializeToken.for token: user_and_token[:token]

        expect(token_deserialized).to include('user_id' => user.id)
      end

      context 'when the user is still unconfirmed' do
        it 'returns nil' do
          user = FactoryGirl.create :user
          service = Sessions::Create.new credential: user.email, password: user.password

          expect(service.process).to be_nil
        end
      end
    end

    context 'when the wrong credentials are present' do
      it 'returs nil' do
        user = FactoryGirl.create :user
        service = Sessions::Create.new credential: 'wrong_credential', password: 'wrong_password'

        expect(service.process).to be_nil
      end
    end
  end
end
