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
      flash[:notice] = notranslate 'Room was successfully created.'
      redirect_to :action => 'index'
    else
      flash[:notice] = notranslate error_messages @room
      redirect_to :action => 'index'
    end
  end

  def update
    @room = Room.find(params[:id])

    if @room.update_attributes(params[:room])
      flash[:notice] = notranslate 'Room was successfully updated'
      redirect_to :action => 'index'
    else
      flash[:notice] = notranslate error_messages @room
      redirect_to :action => 'index'
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    flash[:notice] = notranslate 'Room was deleted'
    redirect_to :action => 'index'
  end
end

