require 'rails_helper'

describe Utils::GenerateToken do
  describe '#process' do

    context 'when a well formated token is present' do
      it 'returns a hash with data' do
        data = { user_id: 1, created_at: Time.now.to_i, data: {} }
        token = JWT.encode data, Rails.application.secrets.secret_key_base, 'HS256'

        service = Utils::DeserializeToken.new token: token
        deserialized_token = service.process

        expect(deserialized_token).to be_a_kind_of(Hash)
        expect(deserialized_token).to include('user_id' => data[:user_id], 'created_at' => data[:created_at], 'data' => {} )
      end
    end

    context 'when an erratictoken is present' do
      it 'returns nil' do
        token = 'erratic token'

        service = Utils::DeserializeToken.new token: token
        deserialized_token = service.process

        expect(deserialized_token).to be_nil
      end
    end

  end
end
