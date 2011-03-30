require 'digest/sha1'

#
# This adds another validator to rails' army. This will check if the password attribute
# isn't blank. The problem with the password is that it is hashed for extra security.
# This is done to make sure that the validations don't crash if there isn't a password
# entered.
#
class PasswordNonBlankValidator < ActiveModel::EachValidator
  # a function needed to be overwritten so rails doesn't complain
  def validate_each record, attribute, value
    record.errors[attribute] << "missing password" if record.hashed_password.blank?
  end
end

# == Schema Information
# Schema version: 20110228145452
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  username               :string(255)
#  name                   :string(255)
#  access_level           :integer
#  salt                   :string(255)
#  hashed_password        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  prefered_language      :string(255)     default("en")
#  forgotten_password_key :string(255)
#
# This table is used to store everything about a user from their password
# to their prefered_language. This model also sends an email to the user
# with their password if it is created.
#
class User < ActiveRecord::Base
  has_many :bookings, :dependent => :destroy

  # access_levels are very important in this system. There are three.
  # 1. Teacher - These can make bookings and change their own settings.
  # 2. Admin - These can make bookings, auto_book and change their own settings.
  # 3. Root - These can make bookings, auto_book, change their own settings, log in as if
  # they were someone else, create rooms, users and term_dates and delete them aswell.
  ACCESS_LEVELS = [
    # Displayed             stored in db
    ["Teacher",             1],
    ["Admin",               3],
    ["Root",                5]
  ]

  # before the validation when the user is created
  before_validation :on => :create do
    unless @password
      # create a new salt for the password
      create_new_salt
      # create a random password
      users_password = Digest::SHA1.hexdigest(rand.to_s)[0,7]
      # and set the password
      self.password = users_password
      # send an email to the user telling them their password etc.
      Notifier.password_notification(self, users_password).deliver
    end
  end

  validates :username, :uniqueness => true, :presence => true
  validates :name, :presence => true
  validates :password, :confirmation => true, :password_non_blank => true
  validates :access_level, :inclusion => {:in => ACCESS_LEVELS.map{|disp, val| val}}

  # This authenticates the user by searching through the database for the username
  # given and finds if the password given is correct.
  #
  # params
  # name The name given
  # password The password given
  def self.authenticate name, password
    # find the user firstly stripping the username of all whitespaces
    user = self.find_by_username(name.strip)
    # if the user was found
    if user
      # check if the password given was correct
      expected_password = User.encrypted_password password, user.salt

      if user.hashed_password != expected_password
        user = nil
      end
    end

    user
  end

  # because password is a virtual attribute, this is used to make sure
  # activerecord doesn't look in the database for it. This variable is only there
  # if the user has just been created.
  def password
    @password
  end

  # This sets the virtual password and also sets the hashed_password behind the scenes.
  def password= pwd
    @password = pwd
    return if pwd.blank?
    create_new_salt

    # set the hashed_password
    self.hashed_password = User.encrypted_password self.password, self.salt
  end

  # This sets the salt to something random
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  # This function encrypts the password with a 1 way hashing algorithm. This means that
  # someone with db access cannot find out the password of someone.
  #
  # params
  # password - the password to hash
  # salt - the desired salt
  def self.encrypted_password password, salt
    # adds a random keyboard splat just to make it interesting
    string_to_hash = password + "sl;dkfj" + salt
    # and hexdigests it to make a long and unintelligent string
    Digest::SHA1.hexdigest string_to_hash
  end

  # Used in the setting of the new password. Has no use elsewhere
  def old_password
  end

  # Used in the setting of the new password. Has no use elsewhere
  def old_password= pwd
  end

  # This will generate the forgotten password key if someone has forgotten their password. It
  # will generate it with a hexdigest command (the same as the one in encrypt_password)
  def generate_forgotten_password_key
    # create the string to hash
    string_to_hash = "#{self.hashed_password}sdfasdf#{self.salt}"
    # and hash it. This would be long and complicated and also difficult to hack
    hash = Digest::SHA1.hexdigest string_to_hash

    # return the hash
    hash
  end
end

