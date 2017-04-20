require 'rails_helper'

describe Sessions do
  describe ".configuration" do
    it 'returns the Sessions Configuration object' do
      expect(Sessions.configuration).to be_instance_of(Sessions::Configuration)
    end
  end

  describe ".configure" do
    before :each do
      Sessions.configure do |config|
        config.session_token_time_alive = 20.days
      end
    end

    it 'should be configured to accept 20 days to be a token alive' do
      expect(Sessions.configuration.session_token_time_alive).to eq 20.days
    end
  end
end
