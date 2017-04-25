require 'rails_helper'

describe Users::RequestResetPassword do
  describe '#process' do
    context 'when a confirmed user credential is present' do
      it 'set the reset password attributos to the user' do
        user = FactoryGirl.create :user, :confirmed
        service = Users::RequestResetPassword.new credential: user.username

        result = service.process

        user.reload

        expect(result).to eq(user)
        expect(user.reset_password_token).to_not be_nil
        expect(user.reset_password_sent_at).to_not be_nil
      end
    end

    context 'when the credential of an unconfirmed user is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :confirmation_open

        service = Users::RequestResetPassword.new credential: user.username

        expect(service.process).to be_nil
        expect(user).to_not be_reset_password_requested
      end
    end

    context 'when an erratic credential is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :confirmed

        service = Users::RequestResetPassword.new credential: 'erratic credential'

        expect(service.process).to be_nil
        expect(user).to_not be_reset_password_requested
      end
    end
  end
end
