class Room < ActiveRecord::Base
  has_many :bookings

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:minimum => 4}
  validates :number_of_computers, :presence => true, :numericality => {:only_integer => true}, :inclusion => {:in => 1..100,
    :message => 'You must enter a sensible number of computers'}
end

