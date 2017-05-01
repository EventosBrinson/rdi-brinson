class UserMailerPreview < ActionMailer::Preview
  def invitation_mail_preview
    UserMailer.invitation_mail(User.first)
  end

  def password_changed_mail_preview
    UserMailer.password_changed_mail(User.first)
  end

  def reset_password_mail_preview
    UserMailer.reset_password_mail(User.first)
  end

  def welcome_mail_preview
    UserMailer.welcome_mail(User.first)
  end
end
