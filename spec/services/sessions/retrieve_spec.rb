require 'rails_helper'

describe Sessions::Retrieve do
  describe '#process' do
    context 'when the right token is present' do
      it 'returs a user and a new token' do
        user = FactoryGirl.create :user
        token = Sessions::Create.for credential: user.username, password: user.password

        service = Sessions::Retrieve.new token: token
        result = service.process

        expect(result[:user]).to eq(user)
        expect(result[:token]).to be_kind_of(String)
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
