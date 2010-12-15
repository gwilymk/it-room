class RoomsController < ApplicationController
  before_filter :auth5

  def index
    @rooms = Room.order('rooms.name')
  end

  def new
    @room = Room.new

    respond_to do |format|
      format.js
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def create
    @room = Room.new(params[:room])

    if @room.save
      flash[:notice] = 'Room was successfully created.'
      redirect_to :action => 'index'
    else
      flash[:notice] = error_messages @room
      redirect_to :action => 'index'
    end
  end

  def update
    @room = Room.find(params[:id])

    if @room.update_attributes(params[:room])
      flash[:notice] = 'Room was successfully updated'
      redirect_to :action => 'index'
    else
      flash[:notice] = error_messages @room
      redirect_to :action => 'index'
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    flash[:notice] = 'Room was deleted'
    redirect_to :action => 'index'
  end
end

