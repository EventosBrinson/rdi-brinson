class UserMailerPreview < ActionMailer::Preview
  def invitation_mail_preview
    UsersMailer.invitation_mail(User.first)
  end

  def password_changed_mail_preview
    UsersMailer.password_changed_mail(User.first)
  end

  def reset_password_mail_preview
    UsersMailer.reset_password_mail(User.first)
  end

  def welcome_mail_preview
    UsersMailer.welcome_mail(User.first)
  end
end
