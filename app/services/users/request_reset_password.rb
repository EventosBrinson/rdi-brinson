module Users
  class RequestResetPassword
    extend ProcessWrapper

    attr_reader :credential

    def initialize(credential:)
      @credential = credential
    end

    def process
      user if user and user.confirmed? and user.update(reset_password_token: Utils::GenerateToken.for(data: { user_id: user.id, created_at: Time.now.to_i }), reset_password_sent_at: Time.now)
    end

    private

    def user
      @user ||= User.find_by_credential credential
    end
  end
end
