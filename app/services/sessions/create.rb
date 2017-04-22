module Sessions
  class Create
    extend ProcessWrapper

    attr_reader :credential, :password

    def initialize(credential:, password:)
      @credential, @password = credential, password
    end

    def process
      user = User.find_by_credential credential

      if user and user.confirmed? and user.authenticate(password)
        token = Utils::GenerateToken.for data: { user_id: user.id, created_at: Time.now.to_i }

        return { user: user, token: token }
      end
    end
  end
end
