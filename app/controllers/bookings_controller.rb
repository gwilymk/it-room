#
# This controller handles everything to do with bookings (except auto_book) including creating
# and deleting. It also allows for searching for a room with enough space.
#
class BookingsController < ApplicationController
  # Make sure that a user is acctulally logged in
  before_filter :auth1, :except => :call_ids_by_type

  # Shows the page which the user can make the bookings with. This is routes to /bookings
  def index
    @booking = Booking.new
  end

  # This action returns a list of Room objects which have enough space on the day, lesson number and number of pupils
  # specified. This takes into account all the rooms and all the bookings made for that room.
  def search
    # The array of results
    @results = []

    # Iterate though all the rooms
    Room.all.each do |room|
      # Create a hash for the current result
      result = {}

      # get the number of computers remaining for that lesson and date for the Room room
      noc_remaining = room.number_remaining(format_date(params['booking']['date']).to_date, params['booking']['lesson_number'].to_i)

      # if there is enough space in that room
      if noc_remaining >= params['booking']['number_of_computers'].to_i
        # set the room name in the result hash
        result[:room] = room.name
        # set the number of places remaining in the hash
        result[:places] = noc_remaining

        # set the room_id
        result[:room_id] = room.id
        # set the date
        result[:date] = params['booking']['date']

        # set the number_of_computers asked for in the hash and the lesson number
        result[:number_of_computers] = params['booking']['number_of_computers']
        result[:lesson_number] = params['booking']['lesson_number']

        # add the hash to the array of results
        @results << result
      end
    end
  end

  def get_reasons
    @result = {}
    @result[:room_id] = params[:room].to_i
    @result[:date] = format_date(params[:date]).to_date
    @result[:number_of_computers] = params[:number_of_computers].to_i
    @result[:lesson_number] = params[:lesson_number].to_i
  end

  def call_ids_by_type
    puts session

    @element_list = I18n.t('ict_areas')[params[:selected].to_i][:levels].map { |key, value| [value, key] }
    render :layout => false
  end

  # This action is called when the booking is acctually made. It will take some values from the params
  # and create a booking from it.
  def book
    # create the booking
    @booking = Booking.new

    # set the values
    @booking.room_id = params[:room].to_i
    @booking.user_id = session[:user_id]
    @booking.date = format_date(params[:date]).to_date
    @booking.number_of_computers = params[:number_of_computers].to_i
    @booking.lesson_number = params[:lesson_number].to_i


    @booking.reason = params[:reason]
    @booking.ict_area = params[:ict_area].to_i
    @booking.ict_level = params[:level].to_i

    # if the save was successfull
    if !@booking.reason.blank? && @booking.save
      # tell the user it was
      flash[:notice] = I18n.t("booking.book.success")
    else
      # or wasn't
      flash[:notice] = I18n.t("booking.book.not_success")
      # and why

      flash[:notice] << "<br />" << error_messages(@booking, I18n.t('booking.reasons.no_reason'))
    end

    flash[:notice] = notranslate(flash[:notice])

    # redirect them to the index URL (e.g. /bookings or where they started)
    redirect_to :action => 'index'
  end

  # Gets a list of bookings for the current user which are later than today
  # and also ordered by date and then by lesson number
  def my_bookings
    @bookings = Booking.where(:user_id => session[:user_id]).where('date >= ?', Date.today).order('date ASC, lesson_number ASC')
  end

  # Deletes the booking supplied.
  def delete
    # finds the booking wanted
    @booking = Booking.find(params[:id])

    # if the booking belongs to the user and it is successfully destroyed
    if @booking.user_id == session[:user_id] && @booking.destroy
      # tell them so
      flash[:notice] = "booking.delete.deleted"
    else
      # or tell them that it didn't work
      flash[:notice] = "booking.delete.fail"
    end

    # redirect them back to the page they were at
    redirect_to bookings_my_bookings_path
  end
end

