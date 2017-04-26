require 'rails_helper'

describe Users::ResetPassword do
  describe '#process' do
    context 'when a confirmed user and right password are present' do
      it 'change the password and reset the reset_password attributes' do
        user = FactoryGirl.create :user, :reset_password_requested
        service = Users::ResetPassword.new token: user.reset_password_token, password: 'supersecret'

        result = service.process

        expect(result).to eq(user)
        expect(result.reset_password_token).to be_nil
        expect(result.reset_password_sent_at).to be_nil
        expect(result.password).to eq 'supersecret'
      end
    end

    context 'when a passed reset password token is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :reset_password_requested
        passed_reset_password_token = user.reset_password_token
        user = Users::RequestResetPassword.for credential: user.username

        service = Users::ResetPassword.new token: passed_reset_password_token, password: 'irelevant_password'

        user.reload

        expect(service.process).to be_nil
        expect(user).to be_reset_password_requested
      end
    end

    context 'when an erratic token is present' do
      it 'returns nil' do
        user = FactoryGirl.create :user, :reset_password_requested

        service = Users::ResetPassword.new token: 'erratic token', password: 'irelevant_password'

        user.reload

        expect(service.process).to be_nil
        expect(user).to be_reset_password_requested
      end
    end
  end
end
