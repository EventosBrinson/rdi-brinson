require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "invitation mail" do
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

      expect(mail.body.encoded).to match('Hola ' + user.fullname)
    end
  end

  describe "password changed mail" do
    it "should render the headers" do
      user = FactoryGirl.create :user
      mail = UserMailer.password_changed_mail(user)

      expect(mail.subject).to eq("Cambio de contraseña")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["staff@eventosbrinson.com"])
    end

    it "should render the body" do
      user = FactoryGirl.create :user
      mail =  UserMailer.password_changed_mail(user)

      expect(mail.body.encoded).to match('Hola ' + user.fullname)
    end
  end

  describe "reset password mail" do
    it "should render the headers" do
      user = FactoryGirl.create :user
      mail = UserMailer.reset_password_mail(user)

      expect(mail.subject).to eq("Petición de cambio de contraseña")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["staff@eventosbrinson.com"])
    end

    it "should render the body" do
      user = FactoryGirl.create :user, :reset_password_requested
      mail =  UserMailer.reset_password_mail(user)

      expect(mail.body.encoded).to match('Hola ' + user.fullname)
    end
  end

  describe "confirmation mail" do
    it "should render the headers" do
      user = FactoryGirl.create :user, :confirmation_open
      mail = UserMailer.confirmation_mail(user)

      expect(mail.subject).to eq("Confirmación de correo")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["staff@eventosbrinson.com"])
    end

    it "should render the body" do
      user = FactoryGirl.create :user, :confirmation_open
      mail =  UserMailer.confirmation_mail(user)

      expect(mail.body.encoded).to match('Hola ' + user.fullname)
    end
  end

  describe "welcome mail" do
    it "should render the headers" do
      user = FactoryGirl.create :user
      mail = UserMailer.welcome_mail(user)

      expect(mail.subject).to eq("Bienvenido a RDIBrinson")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["staff@eventosbrinson.com"])
    end

    it "should render the body" do
      user = FactoryGirl.create :user
      mail =  UserMailer.welcome_mail(user)

      expect(mail.body.encoded).to match('Hola ' + user.fullname)
    end
  end
end
