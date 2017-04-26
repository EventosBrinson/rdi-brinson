module Users
  class ResetPassword
    extend ProcessWrapper

    attr_reader :token, :password

    def initialize(token:, password:)
      @token, @password = token, password
    end

    def process
      user if user and user.update(reset_password_token: nil, reset_password_sent_at: nil, password: filtered_password)
    end

    private

    def filtered_password
      password == '' ? 'NaN' : password
    end

    def user
      @user ||= user_from_token
    end

    def user_from_token
      token_data = Utils::DeserializeToken.for token: token
      user = User.find(token_data['user_id']) if token_data
      user if user and user.reset_password_token == token
    end
  end
end
