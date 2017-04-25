class UserMailer < ApplicationMailer
  def invitation_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Invitación al sistema IRD Brinson')
  end

  def reset_password_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Petición de cambio de contraseña')
  end
end
