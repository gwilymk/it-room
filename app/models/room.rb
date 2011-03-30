# == Schema Information
# Schema version: 20110228145452
#
# Table name: rooms
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  number_of_computers :integer
#  created_at          :datetime
#  updated_at          :datetime
#
# This is a wrapper around the rooms database table.
#
class Room < ActiveRecord::Base
  # a room has many bookings and when a room is destroyed, so
  # are all the bookings associated with it.
  has_many :bookings, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:minimum => 4}
  validates :number_of_computers, :presence => true, :numericality => {:only_integer => true}, :inclusion => {:in => 1..100, :message => 'You must enter a sensible number of computers'}

  # this function will find the number of spaces remaining for the current
  # room for date _date_ and lesson_number _lesson_number_.
  def number_remaining date, lesson_number
    # get the number of computers for this room
    noc_remaining = self.number_of_computers
    # find all the bookings where the date is the date given and the lesson number is the one given
    self.bookings.where(:date => date, :lesson_number => lesson_number).each do |booking|
      # subtract the number of computers in the booking
      noc_remaining -= booking.number_of_computers
    end

    # and return the number remaining
    noc_remaining
  end
end

