module TimetableHelper
  def format_bookings bookings
    @result = "<table id=\"booking\">"

    computers_remaining = nil

    if bookings.first && room = Room.find_by_id(bookings.first.room_id)
      computers_remaining = room.number_of_computers
    end

    bookings.each do |i|
      @result << "<tr>"
      @result << "<td>" << User.find(i.user_id).name << "</td>"
      @result << "<td>" << i.number_of_computers.to_s << "</td>"

      computers_remaining -= i.number_of_computers
      @result < "</tr>"
    end

    if computers_remaining
      @result << "<tr>"
      @result << "<td colspan=\"3\">"
      @result << "#{computers_remaining} places remaining"
      @result << "</td></tr>"
    end
    @result << "</table>"

    @result.html_safe
    @result
  end
end

