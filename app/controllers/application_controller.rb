class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  attr_reader :current_user, :new_token

  rescue_from CanCan::AccessDenied, with: :access_denied

  private

  def authenticate_request
    @current_user = Sessions::Retrieve.for token: request.headers[:HTTP_AUTH_TOKEN] || request.cookies['ssid']
    head :forbidden unless @current_user
  end

  def access_denied
    head :forbidden
  end
end
