require 'spec_helper'

describe Booking do
  let(:room) {
    room3 = Room.new(:name => 'Room 3', :number_of_computers => 60)
    room3.save!
    room3
  }

  let(:user) {
    bob = User.new(:name => 'Bob the Builder', :username => 'bb', :password => 'secret', :password_confirmation => 'secret', :access_level => 1)
    bob.save!
    bob
  }

  let(:booking) { Booking.new(:room => room, :user => user, :date => Date.today, :number_of_computers => 10, :lesson_number => 2) }

  subject do
    b = Booking.new(:room => room, :user => user, :date => Date.today, :number_of_computers => 10, :lesson_number => 1)
    b.save!
    b
  end

  it { should be_valid }
  its(:room) { should == room }
  its(:user) { should == user }
  its(:number_of_computers) { should == 10 }
  its(:date) { should == Date.today }
  its(:lesson_number) { should == 1 }

  it "should validate the lesson_number (correct values)" do
    (1..6).each do |number|
      booking.lesson_number = number
      booking.should be_valid
    end
  end

  it "should validate the lesson_number (incorrect values)" do
    [-1, 7, 'a'].each do |invalid_lesson|
      booking.lesson_number = invalid_lesson
      booking.should_not be_valid
    end
  end

  it "should not be valid if there isn't enough space" do
    booking.number_of_computers = room.number_of_computers
    booking.lesson_number = 3

    booking.should be_valid
    booking.number_of_computers += 1

    booking.should_not be_valid
  end
end

