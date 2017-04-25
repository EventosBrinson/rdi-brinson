require 'rails_helper'

describe Users::Confirmation do
  describe '#process' do
    context 'when a pending user and right password are present' do
      it 'confirm and return the user and set the user password' do
        user = FactoryGirl.create :user, :confirmation_open
        service = Users::Confirmation.new token: user.confirmation_token, password: 'supersecret'

        result = service.process

        user.reload

        expect(result).to eq(user)
        expect(user.confirmation_token).to be_nil
        expect(user.confirmation_sent_at).to be_nil
        expect(user.confirmed_at).to_not be_nil
      end
    end

    context 'when a passed confirmation token is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :confirmation_open
        passed_confirmation_token = user.confirmation_token
        user = Users::OpenConfirmation.for user: user

        service = Users::Confirmation.new token: passed_confirmation_token, password: 'irelevant_password'

        expect(service.process).to be_nil
        expect(user).to be_pending
      end
    end

    context 'when an erratic token is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :confirmation_open

        service = Users::Confirmation.new token: 'erratic token', password: 'irelevant_password'

        expect(service.process).to be_nil
        expect(user).to be_pending
      end
    end
  end
end
