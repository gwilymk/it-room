#
# This controller handles term dates. It is probably one of the most simple
# along with RoomController
#
class TermDatesController < ApplicationController
  # Make sure the user is of access level root or above
  before_filter :auth5

  # Create a list of all the TermDates
  def index
    @term_dates = TermDate.all
  end

  # Creates a tempory TermDate for creation after the user has finished with it.
  def new
    @term_date = TermDate.new
  end

  # Find the term date wanted and give the user a dialog to edit it
  def edit
    @term_date = TermDate.find(params[:id])
  end

  # Creates a new TermDate from what the user specified
  def create
    # Creates the initial term date
    @term_date = TermDate.new(params[:term_date])

    # Do some date formatting Voodoo which Ruby 1.8.7 needs
    @term_date.term_begin = format_date params[:term_date][:term_begin]
    @term_date.term_end = format_date params[:term_date][:term_end]

    # if it saves successfully
    if @term_date.save
      # tell the user it did
      flash[:notice] = notranslate 'Term date was successfully created.'
      # and redirect them to the index
      redirect_to :action => 'index'
    else
      # otherwise tell them that there was an error
      flash[:notice] = notranslate error_messages @term_date
      # and again, redirect to the index
      redirect_to :action => 'index'
    end
  end

  # This will update the term date with the changed attributes. This will be
  # used if the term date was entered incorrectly and/or dates were changed.
  def update
    # find the term_dates
    @term_date = TermDate.find(params[:id])

    # update the attributes
    if @term_date.update_attributes(params[:term_date])
      # tell them it worked
      flash[:notice] = notranslate 'Term date was successfully updated'
      # and redirect
      redirect_to :action => 'index'
    else
      # tell them why it didn't work
      flash[:notice] = notranslate error_messages(@term_date)
      # and redirect
      redirect_to :action => 'index'
    end
  end

  # This is called if the term_date needs deleteing
  def destroy
    # find the term_date
    @term_date = TermDate.find(params[:id])
    # and destroy it
    @term_date.destroy

    # tell the user it was destroyed
    flash[:notice] = notranslate 'Term date was deleted'
    # and redirect
    redirect_to :action => 'index'
  end
end

