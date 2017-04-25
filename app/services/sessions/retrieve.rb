module Sessions
  class Retrieve
    extend ProcessWrapper

    attr :token

    def initialize(token:)
      @token = token
    end

    def process
      data = Utils::DeserializeToken.for token: token

      if data and (Time.at(data['created_at']) + Sessions.configuration.session_token_time_alive) >= Time.now
        User.find_by_id data['user_id']
      end
    end
  end
end
