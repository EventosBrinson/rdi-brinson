class UserMailer < ApplicationMailer
  def invitation_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Invitación al sistema IRD Brinson')
  end
end
