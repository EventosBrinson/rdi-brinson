module Utils
  class DeserializeToken
    extend ProcessWrapper

    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def process
      begin
       JWT.decode(token, secret, true, { :algorithm => 'HS256' })[0]
      rescue JWT::DecodeError
        nil
      end
    end

    private

    def secret
      Rails.application.secrets.secret_key_base
    end
  end
end
