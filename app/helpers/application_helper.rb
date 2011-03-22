#
# This module contains all sorts of miscellaneous functions used in
# the controllers. As this model is included into the ApplicationController
# which in turn is subclassed by all models, this module is avalible to
# all controllers
#
module ApplicationHelper
  # This function is used to format the date if the ruby version is too low
  # for the system to handle. If the ruby version is >= 1.9.2, then this function
  # is not needed, whereas, if the ruby version is 1.8.7 (ie. Heroku) then it
  # is needed.
  def format_date date
    # if the ruby version is the one on Heroku
    if RUBY_VERSION == "1.8.7"
      # split the date into three sections sepearated by a '/'
      day, month, year = date.split(/\//)
      # and return the way ruby 1.8.7 likes it
      "#{year}-#{month}-#{day}"
    else
      # otherwise just return the input given as ruby 1.9.2 doesn't mind it
      date
    end
  end

  # In the layout, a dialog box is shown if something happens. However, I wish for this
  # box to be translatable. This function called on a string which needs not to be
  # translated. This is because if it is translated, there world be some strange errors.
  # The layout does a simple check to see if the message needs translating. If it does,
  # then it translates it. If it doesn't, then this method has been called on it and the
  # translation doesn't happen. This function is increibly simple. All it does is add the
  # text "NOTRANSLATE" to the start of the string entered.
  def notranslate string
    # return the srting prefixed with NOTRANSLATE
  	"NO TRANSLATE#{string}"
  end

  # This returns a simple un-ordered list with all the error messages for an item. This is
  # mainly used in the database access things as it returns a simple list in HTML form which
  # can be rendered by a web page
  def error_messages thing
    # start the notice with the word error (translated)
    notice = I18n.t("errors.error")
    # start the unordered list
    notice << "<ul>"
    # go through each error message
    thing.errors.full_messages.each do |msg|
      # and add a list item for each one
      notice << "<li>" << msg << "</li>"
    end

    # terminate the list
    notice << "</ul>"

    # and return the notice
    notice
  end
end

