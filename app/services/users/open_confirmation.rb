module Users
  class OpenConfirmation
    extend ProcessWrapper

    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def process
      user if user.update confirmation_token: Utils::GenerateToken.for(data: { user_id: user.id, created_at: Time.now.to_i }),
                          confirmation_sent_at: Time.now,
                          confirmed_at: nil
    end
  end
end
