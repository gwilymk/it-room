require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  fixtures :users, :term_dates

  test "empty attribues fail" do
    room = Room.new
    assert !room.valid?
    assert room.errors.any?
  end

  test "valid number of computers" do
    room = Room.new :name => "awesome" # has to have a valid name

    room.number_of_computers = -5
    assert !room.valid?
    assert_equal 'You must enter a sensible number of computers', room.errors.first[1]

    room.number_of_computers = 20 #valid
    assert room.valid?

    room.number_of_computers = 150 #not valid
    assert !room.valid?
    assert_equal 'You must enter a sensible number of computers', room.errors.first[1]

    room.number_of_computers = 15.4
    assert !room.valid?
  end

  test "uniqueness of name" do
    room = Room.new :name => "room1", :number_of_computers => 15
    assert room.save

    room2 = Room.new :name => "room1", :number_of_computers => 14
    assert !room2.valid?
    assert !room2.save

    room3 = Room.new :name => "rOOm1", :number_of_computers => 13 # case sensetive = true
    #    not the number zero    ^^
    assert !room3.valid?
    assert !room3.save
  end

  test "length of name" do
    room = Room.new :name => "one_computer", :number_of_computers => 1
    assert room.valid? #so we know it is the name

    room.name = "one" #too short
    assert !room.valid?
  end

  test "number of computers remaining" do
    date = Date.today.tomorrow
    lesson_number = 2
    room = rooms(:room3)

    booking = Booking.new(:room_id => room.id, :user_id => users(:joe).id, :number_of_computers => 5, :date => date, :lesson_number => lesson_number)
    assert booking.save, booking.errors.full_messages.join('\n')

    assert_equal (room.number_of_computers - 5), room.number_remaining(date, lesson_number)

    booking2 = Booking.new(:room_id => room.id, :user_id => users(:bob).id, :number_of_computers => 6, :date => date, :lesson_number => lesson_number)
    assert booking2.save

    assert_equal (room.number_of_computers - 11), room.number_remaining(date, lesson_number)
  end
end

