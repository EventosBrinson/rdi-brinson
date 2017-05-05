class SessionsController < ApplicationController
  before_action :authenticate_request, only: [:register, :sign_out]

  def confirm
    @user = Users::Confirmation.for token: params[:token], password: params[:password]

    if @user
      @token = Sessions::Create.for credential: @user.username, password: @user.password
      UserMailer.welcome_mail(@user).deliver_now

      render template: 'sessions/show.json'
    else
      head :bad_request
    end
  end

  def request_reset_password
    @user = Users::RequestResetPassword.for credential: params[:credential]

    UserMailer.reset_password_mail(@user).deliver_now if @user

    head :ok
  end

  def reset_password
    @user = Users::ResetPassword.for token: params[:token], password: params[:password]

    if @user
      @token = Sessions::Create.for credential: @user.username, password: @user.password
      UserMailer.password_changed_mail(@user).deliver_now

      render template: 'sessions/show.json'
    else
      head :bad_request
    end
  end

  def sign_in
    if session_token
      @user = retrieve_user
      @token = session_token
    else
      @user = User.find_by_credential params[:credential]
      @token = generate_session_token
    end

    if @user and @token
      render template: 'sessions/show.json'
    else
      render json: false
    end
  end

  def sign_out
    if @current_user
      head :ok
    else
      head :bad_request
    end
  end

  private


  def generate_session_token
    Sessions::Create.for credential: params[:credential], password: params[:password]
  end

  def retrieve_user
    Sessions::Retrieve.for token: session_token
  end

  def session_token
    @session_token ||= request.headers[:HTTP_AUTH_TOKEN]
  end

  def user_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :role)
  end
end
