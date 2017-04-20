require 'rails_helper'

describe Utils::GenerateToken do
  describe '#process' do
    it 'returns a token' do
      data = { user_id: 1, created_at: Time.now.to_i, data: {} }

      service = Utils::GenerateToken.new data: data
      token = JWT.encode data, Rails.application.secrets.secret_key_base, 'HS256'

      expect(service.process).to eq token
    end
  end
end
