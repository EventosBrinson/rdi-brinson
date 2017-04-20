module Utils
  class GenerateToken
    extend ProcessWrapper

    attr_reader :data

    def initialize(data:)
      @data = data
    end

    def process
       JWT.encode data, secret, 'HS256'
    end

    private

    def secret
      Rails.application.secrets.secret_key_base
    end
  end
end
