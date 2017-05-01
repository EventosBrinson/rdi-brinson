module WebApp
  class Configuration
    attr_accessor :web_app_url

    def initialize
      @web_app_url = 'http://web-app.com'
    end
  end
end
