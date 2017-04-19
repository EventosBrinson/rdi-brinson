require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "invite" do

    it "should render the headers" do
      user = FactoryGirl.create :user
      mail = UserMailer.invitation_mail(user)

      expect(mail.subject).to eq("Invitación al sistema IRD Brinson")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["staff@eventosbrinson.com"])
    end

    it "should render the body" do
      user = FactoryGirl.create :user
      mail =  UserMailer.invitation_mail(user)

      expect(mail.body.encoded).to match('Hi ' + user.fullname)
    end
  end
end
