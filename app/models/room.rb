class Room < ActiveRecord::Base
  has_many :bookings, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:minimum => 4}
  validates :number_of_computers, :presence => true, :numericality => {:only_integer => true}, :inclusion => {:in => 1..100,
    :message => 'You must enter a sensible number of computers'}

  def number_remaining date, lesson_number
    noc_remaining = self.number_of_computers
    self.bookings.where(:date => date, :lesson_number => lesson_number).each do |i|
      noc_remaining -= i.number_of_computers
    end

    noc_remaining
  end
end

