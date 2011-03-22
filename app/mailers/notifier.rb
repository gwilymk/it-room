#
# This is the model which send the emails.
#
class Notifier < ActionMailer::Base
  # this means that all emails will come by default from the email address
  # it-room@llanfyllin-hs.powys.sch.uk
  default :from => "it-room@llanfyllin-hs.powys.sch.uk"

  # This will email the a new user their username and password. This email is
  # only sent once, when the user is created.
  def password_notification recipient, password
    # so the view can 'see' the password
    @password = password
    # works out the email of the user
    account_email = recipient.username + "@llanfyllin-hs.powys.sch.uk"
    # makes the user visible to the view
    @account = recipient

    # sends the email
    mail :to => account_email, :subject => 'New account on it-room'
  end

  # This email is sent when a user forgets their password. The email is sent with a link
  # for the user to press and this will alow them to reset their password
  def forgotten_password recipient, key
    @key = key
    account_email = recipient.username + "@llanfyllin-hs.powys.sch.uk"
    @account = recipient

    mail :to => accont_email, :subject => I18n.t('admin.login.forgotten_password')
  end
end

