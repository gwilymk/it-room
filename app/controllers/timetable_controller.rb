#
# The timetable controller is in charge of displaying the timetable
# to the user. It makes user of the Booking model and the Room model
# and makes no chnage to the database. This is why it is safe to allow
# anyone to access it.
#
# The timetable controller takes some params from the user in a web form
# and with some AJAX magic it will show them the timetable with some
# pretty effects without reloading the page. This speeds up the time it
# takes for the user to see the timetable they are looking for and also
# reduces bandwidth useage
#
class TimetableController < ApplicationController
  # This is the action the user will spend the entire time on as it returns
  # a form which the user can fill in and also brings things entirely by AJAX
  # using the show aciton.
  def index

  end

  # An AJAX call which takes all the parameters and creates a timetable from
  # it. This also has a printer friendly version of it which gives a version
  # without frills.
  def show
    # find the date they want
    @date = format_date(params['date-select']).to_date

    # and keep going back until you get to the Monday. This is used so that
    # we get the first day of the week and can find the whole week for the user.
    # This is done be constantly going back one day until the date is a Monday
    @date = @date.yesterday until @date.monday?

    # We need all the bookings for that room. This is a cache to save time
    @bookings = Booking.where(:room_id => params['room'])
    # This is for the name of the room used in the view
    @room = Room.find(params['room']).name

    # This is the array needed to store all the bookings in the table generated
    # by the view
    @bookings_for_table = []

    # 5 times because there are 5 days to show on the timetable
    5.times do
      # Add the booking to the array needed for the table
      @bookings_for_table << @bookings.where(:date => @date)
      # continue in terms of days
      @date = @date.tomorrow
    end

    # get the week number for the day specified
    @week = TermDate.week @date

    # if the user wants it printer friendly
    if params[:printer_friendly]
      # show i without the layout
      render "show", :layout => false
    end
  end

  def show_reason
    booking = Booking.find(params[:id])

    @reason = booking.reason
    @ict_area = I18n.t("ict_areas")[booking.ict_area][:name]
    @ict_level = I18n.t("ict_areas")[booking.ict_area][:levels][booking.ict_level]
  end
end

