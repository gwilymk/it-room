module ApplicationHelper
  def format_date date
    day, month, year = date.split(/\//)
    "#{year}-#{month}-#{day}"
  end

  def notranslate string
  	"NO TRANSLATE#{string}"
  end
end

