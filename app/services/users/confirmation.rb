module Users
  class Confirmation
    extend ProcessWrapper

    attr_reader :token, :password

    def initialize(token:, password:)
      @token, @password = token, password
    end

    def process
      user if user and user.update(confirmation_token: nil, confirmation_sent_at: nil, confirmed_at: Time.now, password: password)
    end

    private

    def user
      @user ||= user_from_token
    end

    def user_from_token
      token_data = Utils::DeserializeToken.for token: token
      user = User.find(token_data['user_id']) if token_data
      user if user and user.confirmation_token == token
    end
  end
end
