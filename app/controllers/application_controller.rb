class ApplicationController < ActionController::API
  attr_reader :current_user, :new_token

  private

  def authenticate_request
    user_and_token = Sessions::Retrieve.for token: request.headers[:HTTP_AUTH_TOKEN]
    @current_user = user_and_token[:user] if user_and_token
    @new_token = user_and_token[:token] if user_and_token
    head :forbidden unless @current_user
  end
end
