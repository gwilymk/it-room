module ApplicationHelper
  def format_date date
    day, month, year = date.split(/\//)
    "#{year}-#{month}-#{day}"
  end

  def notranslate string
  	"NO TRANSLATE#{string}"
  end

  def error_messages thing
    notice = I18n.t("errors.error")
    notice << "<ul>"
    thing.errors.full_messages.each do |msg|
      notice << "<li>" << msg << "</li>"
    end
    notice << "</ul>"

    notice
  end
end

