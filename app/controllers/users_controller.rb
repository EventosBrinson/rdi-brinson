class UsersController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, User
    @users = User.filter(params.slice(:search, :ordered))

    render template: 'users/index.json'
  end

  def show
    authorize! :show, User
    @user = User.find(params[:id])

    render template: 'users/show.json'
  end

  def create
    @user = User.new user_params
    authorize! :create, @user

    if @user.save
      Users::OpenConfirmation.for user: @user
      UserMailer.invitation_mail(@user).deliver_now

      render template: 'users/show.json'
    else
      render json: @user.errors, status: :bad_request
    end
  end

  def update
    @user = User.find params[:id]

    if @user
      @user.assign_attributes user_updatabe_params
      authorize! :update, @user

      email_canged = @user.email_changed?
      password_cahnged = @user.password_digest_changed?

      if @user.save
        if email_canged
          Users::OpenConfirmation.for user: @user
          UserMailer.confirmation_mail(@user).deliver_now
        end
        if password_cahnged
          UserMailer.password_changed_mail(@user).deliver_now
        end

        render template: 'users/show.json'
      else
        render json: @user.errors, status: :bad_request
      end
    else
      head status: 404
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :role)
  end

  def user_updatabe_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :role, :password)
  end
end
