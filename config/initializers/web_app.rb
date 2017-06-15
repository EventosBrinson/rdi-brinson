WebApp.configure do |config|
  config.web_app_url = 'http://localhost:3001' if Rails.env.development?
  config.web_app_url = 'http://rdi.eventosbrinson.com' if Rails.env.production?
end
