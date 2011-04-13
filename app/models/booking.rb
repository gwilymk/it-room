#
# This class makes sure that the date for the date of the booking the person is
# trying to book is within a valid term date.
#
class ValidDateValidator < ActiveModel::EachValidator
  include ApplicationHelper

  # Validate each is a method which needs to be overwritten.
  def validate_each record, attribute, value
    unless Date.today <= record.date && record.date <= TermDate.term_for(record.date).term_end
      record.errors.add attribute, I18n.t('activerecord.errors.messages.invalid_date')
    end
  end
end

#
# This validator makes sure that there is enough space in the room the person is trying to book
#
class ValidSpaceValidator < ActiveModel::EachValidator
  include ApplicationHelper

  # Validate each is a method which needs to be overwritten.
  def validate_each record, attribute, value
    unless record.room.number_remaining(record.date, record.lesson_number) >= record.number_of_computers
      record.errors.add attribute, I18n.t('activerecord.errors.messages.no_space')
    end
  end
end

# == Schema Information
# Schema version: 20110228145452
#
# Table name: bookings
#
#  id                  :integer         not null, primary key
#  user_id             :integer
#  room_id             :integer
#  date                :date
#  lesson_number       :integer
#  number_of_computers :integer
#  created_at          :datetime
#  updated_at          :datetime
#
# The booking class is a wrapper around the bookings database. This is a very simple class
# which manages validations, saving, loading and updating.
#
class Booking < ActiveRecord::Base
  # The lesson numbers. The first is the one displayed on the system, and the second
  # one is the value which has all the algorithms work on it.
  LESSON_NUMBERS = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5], ['6', 6]]

  # These two lines are incredibly powerful. They tell rails that a booking belongs to
  # a user and to a room
  belongs_to :user
  belongs_to :room

  validates :user, :presence => true
  validates :date, :presence => true, :valid_date => true
  validates :number_of_computers, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validates :room, :presence => true, :valid_space => true
  # makes sure the lesson number is one present in the LESSON_NUMBERS
  validates :lesson_number, :presence => true, :inclusion => {:in => LESSON_NUMBERS.map{|disp,val| val}}
  #validates :reason, :presence => true
  #validates :ict_area, :numericality => true
  #validates :ict_level, :numericality => true
end

