module Sessions
  class Retrieve
    extend ProcessWrapper

    attr :token

    def initialize(token:)
      @token = token
    end

    def process
      data = Utils::DeserializeToken.for token: token

      if data and Time.at(data['created_at']) + Sessions.configuration.session_token_time_alive >= Time.now
        user =  User.find_by_id data['user_id']
        new_token = Utils::GenerateToken.for data: { user_id: user.id, created_at: Time.now }
        { user: user, token: new_token }
      end
    end
  end
end
