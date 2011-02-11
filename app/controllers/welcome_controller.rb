class WelcomeController < ApplicationController
  def index
    @week = TermDate.week
    @days_until_end = TermDate.days_until_end
  end
end

