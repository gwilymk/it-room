class TermDatesController < ApplicationController
  before_filter :auth5

  def index
    @term_dates = TermDate.all
  end

  def new
    @term_date = TermDate.new

    respond_to do |format|
      format.js
    end
  end

  def edit
    @term_date = TermDate.find(params[:id])
  end

  def create
    @term_date = TermDate.new(params[:term_date])
    @term_date.term_begin = format_date params[:term_date][:term_begin]
    @term_date.term_end = format_date params[:term_date][:term_end]

    if @term_date.save
      flash[:notice] = notranslate 'Term date was successfully created.'
      redirect_to :action => 'index'
    else
      flash[:notice] = notranslate error_messages @term_date
      redirect_to :action => 'index'
    end
  end

  def update
    @term_date = TermDate.find(params[:id])

    if @term_date.update_attributes(params[:term_date])
      flash[:notice] = notranslate 'Term date was successfully updated'
      redirect_to :action => 'index'
    else
      flash[:notice] = notranslate error_messages @term_date
      redirect_to :action => 'index'
    end
  end

  def destroy
    @term_date = TermDate.find(params[:id])
    @term_date.destroy

    flash[:notice] = notranslate 'Term date was deleted'
    redirect_to :action => 'index'
  end
end

