class UserMailerPreview < ActionMailer::Preview
  def invitation_mail_preview
    UsersMailer.invitation_mail(User.first)
  end
end
