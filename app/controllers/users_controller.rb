class UsersController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, User
    @users = get_users

    render template: 'users/index.json'
  end

  def show
    @user = User.find_by id: params[:id]

    if @user
      authorize! :show, @user

      render template: 'users/show.json'
    else
      head :not_found
    end
  end

  def create
    @user = User.new user_params
    authorize! :create, @user

    if @user.save
      Users::OpenConfirmation.for user: @user
      UserMailer.invitation_mail(@user).deliver_now

      render template: 'users/show.json'
    else
      render json: @user.errors
    end
  end

  def update
    @user = User.find_by id: params[:id]

    if @user
      @user.assign_attributes user_updateable_params
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
        render json: @user.errors
      end
    else
      head :not_found
    end
  end

  private

  def get_users
    params[:search] || params[:ordered] || params[:paginated] ? User.filter(params.slice(:search, :ordered, :paginated)) : User.all
  end

  def user_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :role)
  end

  def user_updateable_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :role, :password)
  end
end
