require 'rails_helper'

describe WebApp do
  describe '.configuration' do
    it 'returns the WebApp Configuration object' do
      expect(WebApp.configuration).to be_instance_of( WebApp::Configuration)
    end
  end

  describe '.configure' do
    before :each do
      WebApp.configure do |config|
        config.web_app_url = 'http://supersite.com'
      end
    end

    it 'should be configured to point to the webapp domain' do
      expect(WebApp.configuration.web_app_url).to eq 'http://supersite.com'
    end
  end

  describe '.reset_password_path' do
    it 'returns the url to reset the password using the web app' do
      user = FactoryGirl.create :user, :reset_password_requested

      expect(WebApp.reset_password_path(user)).to eq(WebApp.configuration.web_app_url + '/reset?token=' + user.reset_password_token )
    end
  end

  describe '.confirmation_path' do
    it 'returns the url to confirm the web app' do
      user = FactoryGirl.create :user, :confirmation_open

      expect(WebApp.confirmation_path(user)).to eq(WebApp.configuration.web_app_url + '/confirmation?token=' + user.confirmation_token )
    end
  end
end
