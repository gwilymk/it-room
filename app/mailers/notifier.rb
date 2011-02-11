class Notifier < ActionMailer::Base
  default :from => "it-room@llanfyllin-hs.powys.sch.uk"

  def password_notification recipient, password
    @password = password
    account_email = recipient.username + "@llanfyllin-hs.powys.sch.uk"
    @account = recipient

    mail :to => account_email, :subject => 'New account on it-room'
  end
end

