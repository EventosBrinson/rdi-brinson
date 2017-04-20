require 'rails_helper'

describe Sessions::Create do
  describe '#process' do
    context 'when the right credentials are present' do
      it 'returs a new token' do
        user = FactoryGirl.create :user
        service = Sessions::Create.new credential: user.email, password: user.password

        expect(service.process).to be_a_kind_of(String)
      end

      it 'returns a token that when deserialized contains the user id' do
        user = FactoryGirl.create :user
        service = Sessions::Create.new credential: user.email, password: user.password
        token = service.process

        token_deserialized = Utils::DeserializeToken.for token: token

        expect(token_deserialized).to include('user_id' => user.id)
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
