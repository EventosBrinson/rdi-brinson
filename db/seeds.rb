omar = User.create firstname: 'David', lastname: 'De Anda', email: 'omarandstuff@gmail.com', username: "omarandstuff", role: User::ROLES[1], main: true
javier = User.create firstname: 'Javier Ivan', lastname: 'Martinez Alvarez', email: 'javier_iv_@hotmail.com', username: "JavierXbolt", role: User::ROLES[0], main: true
Users::OpenConfirmation.for user: omar
Users::OpenConfirmation.for user: javier
UserMailer.invitation_mail(omar).deliver_now
UserMailer.invitation_mail(javier).deliver_now
