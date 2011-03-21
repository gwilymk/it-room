#
# This controller simply displays the index page
#
class WelcomeController < ApplicationController
  # The root URL
  def index
    # tells the user the current week and the number of days until the end of term
    @week = TermDate.week
    @days_until_end = TermDate.days_until_end
  end
end

