module WebApp
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_password_path(user)
    self.configuration.web_app_url + '/reset?token=' + user.reset_password_token.to_s
  end

  def self.confirmation_path(user)
    self.configuration.web_app_url + '/confirmation?token=' + user.confirmation_token.to_s
  end
end
