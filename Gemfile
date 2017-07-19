source 'https://rubygems.org'
ruby "2.3.4"

gem 'rails', '~> 5.1'
gem 'rake'
gem 'pg'
gem 'puma'
gem 'rack-cors'
gem "paperclip"

gem 'jbuilder'
gem 'bcrypt'
gem 'jwt'

gem 'cancancan', '~> 1.10'

group :development, :test do
  gem 'byebug', platform: :mri
  gem "factory_girl_rails"
  gem 'rspec-rails'
  gem 'faker'
end

group :development do
  gem 'capistrano', '~> 3.7', '>= 3.7.1'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem "simplecov"
  gem "codeclimate-test-reporter", "~> 1.0.0"
end
