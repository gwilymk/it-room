require 'test_helper'

class BookingTest < ActiveSupport::TestCase
  fixtures :term_dates, :rooms, :users

  def setup
    @booking = new_booking
  end

  def new_booking
    Booking.new :user_id => users(:joe).id, :room_id => rooms(:room3).id, :date => Date.today.tomorrow, :lesson_number => 4
  end

  test "make booking" do
    @booking.update_attributes :number_of_computers => 5
    assert @booking.valid?

    assert_equal 0, @booking.errors.count
  end

  test "full room" do
    @booking.number_of_computers = rooms(:room3).number_of_computers
    assert @booking.valid?

    @booking.number_of_computers += 1
    assert !@booking.valid?
  end

  test "multiple bookings" do
    @booking.number_of_computers = rooms(:room3).number_of_computers - 10

    assert @booking.save
    booking2 = new_booking
    booking2.user_id = users(:bob).id
    booking2.number_of_computers = 10

    assert booking2.save

    booking3 = new_booking
    booking3.user_id = users(:fred).id
    booking3.number_of_computers = 5

    assert !booking3.valid?
  end

  test "simutanious bookings" do
    @booking.number_of_computers = rooms(:room3).number_of_computers - 10

    booking2 = new_booking
    booking2.number_of_computers = 11

    t = Thread.new do
      @booking.save
    end

    booking2.save

    t.value # wait for thread to finish
    assert_not_equal 2, rooms(:room3).bookings.count
  end
end

