require 'rails_helper'

describe Users::OpenConfirmation do
  describe '#process' do
    context 'when a new user object is present' do
      it 'sets the user confirmetion params and returns the user' do
        user = FactoryBot.create :user
        service = Users::OpenConfirmation.new user: user

        result = service.process

        expect(result).to eq(user)
        expect(user.confirmation_token).to_not be_nil
        expect(user.confirmation_sent_at).to_not be_nil
        expect(user.confirmed_at).to be_nil
      end
    end

    context 'when a confirmed user object is present' do
      it 'sets the user confirmetion params, unconfirm and returns the user' do
        user = FactoryBot.create :user, confirmed_at: Time.now
        service = Users::OpenConfirmation.new user: user

        result = service.process

        expect(result).to eq(user)
        expect(user.confirmation_token).to_not be_nil
        expect(user.confirmation_sent_at).to_not be_nil
        expect(user.confirmed_at).to be_nil
      end
    end
  end
end
