class ApplicationController < ActionController::API
  attr_reader :current_user, :new_token

  private

  def authenticate_request
    @current_user = Sessions::Retrieve.for token: request.headers[:HTTP_AUTH_TOKEN]
    head :forbidden unless @current_user
  end
end
