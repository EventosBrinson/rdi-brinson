source 'https://rubygems.org'
ruby "2.3.3"

gem 'rails', '~> 5.0.1'
gem 'rake', '~> 12.0.0'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'rack-cors', '~> 0.4.1'
#gem 'redis', '~> 3.0'

gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 1.5.6'

group :development, :test do
  gem 'byebug', platform: :mri
  gem "factory_girl_rails", "~> 4.0"
  gem 'capistrano', '~> 3.7', '>= 3.7.1'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rbenv', '~> 2.1'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0.1'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'rspec-rails', '~> 3.5.2'
end
