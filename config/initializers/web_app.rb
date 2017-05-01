WebApp.configure do |config|
  config.web_app_url = 'http://localhost:3001' if Rails.env.development?
end
