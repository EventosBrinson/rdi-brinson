class UserMailer < ApplicationMailer
  def invitation_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Invitación al sistema IRD Brinson')
  end

  def password_changed_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Cambio de contraseña')
  end

  def reset_password_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Petición de cambio de contraseña')
  end

  def welcome_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenido a RDIBrinson')
  end
end
