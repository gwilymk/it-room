require 'digest/sha1'

class PasswordNonBlankValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    record.errors[attribute] << "missing password" if record.hashed_password.blank?
  end
end

class User < ActiveRecord::Base
  has_many :bookings, :dependent => :destroy

  ACCESS_LEVELS = [
    # Displayed             stored in db
    ["Teacher",             1],
    ["Admin",               3],
    ["Root",                5]
  ]

  before_validation :on => :create do
    unless @password
      create_new_salt
      users_password = Digest::SHA1.hexdigest(rand.to_s)[0,7]
      self.password = users_password
      begin
        Notifier.password_notification(self, users_password).deliver
      rescue

      end
    end
  end

  validates :username, :uniqueness => true, :presence => true
  validates :name, :presence => true
  validates :password, :confirmation => true, :password_non_blank => true
  validates :access_level, :inclusion => {:in => ACCESS_LEVELS.map{|disp, val| val}}

  def self.authenticate name, password
    user = self.find_by_username name
    if user
      expected_password = User.encrypted_password password, user.salt

      if user.hashed_password != expected_password
        user = nil
      end
    end

    user
  end

  def password
    @password
  end

  def password= pwd
    @password = pwd
    return if pwd.blank?
    create_new_salt

    self.hashed_password = User.encrypted_password self.password, self.salt
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  private

  def self.encrypted_password password, salt
    string_to_hash = password + "sl;dkfj" + salt
    Digest::SHA1.hexdigest string_to_hash
  end
end

