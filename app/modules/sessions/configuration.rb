module Sessions
  class Configuration
    attr_accessor :session_token_time_alive

    def initialize
      @session_token_remember_time = 10.days
    end
  end
end
