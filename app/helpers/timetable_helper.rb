#
# This module is included in the timetable controller. It is used for functions
# which are not actions.
#
module TimetableHelper
  # This will format the bookings in such a way that they fit nicely in the
  # timetable. It generates the HTML for a single timetable entry.
  #
  # Params
  #  _bookings_ An array of the Booking objects to format
  def format_bookings bookings
    # start the table
    @result = "<table id=\"booking\">"

    # the number of computers remaining in that rom
    computers_remaining = nil

    # if there are any bookings in the array and then find the room
    if bookings.first && room = Room.find_by_id(bookings.first.room_id)
      # number of computers for that room
      computers_remaining = room.number_of_computers
    end

    # each booking
    bookings.each do |booking|
      # generate the HTML
      @result << render(:partial => 'timetable/lesson', :locals => {:booking => booking})

      # deduct from the computers remaining
      computers_remaining -= booking.number_of_computers
    end

    # if computers_remaining isn't nil
    if computers_remaining
      # add a places remaining column
      @result << "<tr>"
      @result << "<td colspan=\"3\">"
      @result << I18n.t('timetable.places_remaining', :number => computers_remaining)
      @result << "</td></tr>"
    end
    # end the table
    @result << "</table>"

    # tell Rails the string is safe
    @result.html_safe
    @result
  end
end

