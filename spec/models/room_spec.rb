require 'spec_helper'

describe Room do
  let(:room) {  Room.new :name => 'Room 3', :number_of_computers => 50 }

  subject do
    room
  end

  it { should be_valid }
  its(:errors) { should be_empty }
  its(:name) { should == 'Room 3' }
  its(:number_of_computers) { should == 50 }

  it "should have fewer computers with one booking" do
    room.save.should be_true
    Booking.new(:room => room, :number_of_computers => 10, :user => mock_model(User, :name => 'asd'), :date => Date.today, :lesson_number => 2).save.should be_true

    room.number_remaining(Date.today, 2).should == 40
  end

  it "should have fewer computers with multiple bookings" do
    room.save.should be_true
    Booking.new(:room => room, :number_of_computers => 10, :user => mock_model(User, :name => 'asd'), :date => Date.today, :lesson_number => 2).save.should be_true
    Booking.new(:room => room, :number_of_computers => 10, :user => mock_model(User, :name => 'asdf'), :date => Date.today, :lesson_number => 2).save.should be_true

    room.number_remaining(Date.today, 2).should == 30
  end

  it "should validate name" do
    room.should be_valid
    room.name = "one" # too short

    room.should_not be_valid
  end

  it "should have a unique name" do
    room.save.should be_true

    room2 = Room.new(:name => room.name, :number_of_computers => 20)
    room2.save.should_not be_true

    room2.name = "Room 33"
    room2.save.should be_true
  end

  it "should have a valid number of computers" do
    room.number_of_computers = -5
    room.should_not be_valid

    room.number_of_computers = 102
    room.should_not be_valid

    room.number_of_computers = 2.33
    room.should_not be_valid

    room.number_of_computers = 30
    room.should be_valid
  end
end

