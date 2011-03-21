#
# This controller handles everything to do with rooms. It requires an access_level
# of root or above. This controller is in charge of creating, reading, updating and
# deleteing of rooms (CRUD) which is essencial to all programs whch require database
# backends
#
class RoomsController < ApplicationController
  # Requires access_level > 5
  before_filter :auth5

  # Shows a list of all the rooms ordered by name.
  def index
    @rooms = Room.order('rooms.name')
  end

  # Doesn't acctually create a new room. This action returns an AJAX request which
  # contains a dialog box for the entry of the new room
  def new
    @room = Room.new

    # Respond with javascript
    respond_to do |format|
      format.js
    end
  end

  # returns the room specified as the id paramter
  def edit
    @room = Room.find(params[:id])
  end

  # Unlike new, this acctually creates the room with the parameters given by the new
  # action. This is a very common patter in RESTful applications which this system is.
  #
  # This action makes sure the room is valid and that it saved properly. If it didn't
  # successfully save, this action will tell them why and possible how to sort it out.
  def create
    # Created a tempory room object from the params given
    @room = Room.new(params[:room])

    # if the room saves
    if @room.save
      # tell the user that it has
      flash[:notice] = notranslate 'Room was successfully created.'
      # and redirect them to the index page
      redirect_to :action => 'index'
    else
      # tell them that there are errors in the input given
      flash[:notice] = notranslate error_messages(@room)
      # and redirect them
      redirect_to :action => 'index'
    end
  end

  # Updates a room. Basically does what the edit action told it to
  # with a bit of error checking
  def update
    # Finds the room which it wants from the params
    @room = Room.find(params[:id])

    # if the attributes given were successfully updates
    if @room.update_attributes(params[:room])
      # tell the user it worked
      flash[:notice] = notranslate 'Room was successfully updated'
      # and redirect them to the index
      redirect_to :action => 'index'
    else
      # otherwise tell them why it didn't work
      flash[:notice] = notranslate error_messages(@room)
      # and redirect them back to the index
      redirect_to :action => 'index'
    end
  end

  # This destroys the room and removes it from the database. Rails names are given to this
  # action as there is a subtle but important difference to delete and destroy. When delete
  # is called, the item is removed from the database with no questions asked. If destroy
  # was called, then rails will make sure all the callbacks are called.
  def destroy
    # Find the room asked for
    @room = Room.find(params[:id])
    # and destroy it
    @room.destroy

    # give the user a reassuring message
    flash[:notice] = notranslate 'Room was deleted'
    # and redirect them back to the index
    redirect_to :action => 'index'
  end
end

