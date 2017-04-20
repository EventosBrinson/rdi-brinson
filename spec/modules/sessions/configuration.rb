require 'rails_helper'

describe Sessions::Configuration do
  describe "#session_token_time_alive" do
    it "default value is 10 days" do
      expect(Sessions::Configuration.new.session_token_time_alive).to eq 10.days
    end
  end

  describe "#session_token_time_alive=" do
    it "can set value" do
      config = Sessions::Configuration.new
      config.session_token_time_alive = 7.days
      expect(config.session_token_time_alive).to eq(7.days)
    end
  end
end
