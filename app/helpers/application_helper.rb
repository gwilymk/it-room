module ApplicationHelper
  def term_end
    APP_CONFIG['term']['end']
  end

  def save_config
    to_save = YAML::dump APP_CONFIG
    File.open APP_CONFIG_FILE, "w" do |file|
      file.puts to_save
    end
  end

  def week date = Date.today
    week_number = date.to_date.cweek % 2 + 1
    if invert_week?
      if week_number == 1
        week_number = 2
      else
        week_number = 1
      end
    end

    week_number
  end

  def invert_week?
    APP_CONFIG['week']['invert']
  end

  def format_date date
    day, month, year = date.split(/\//)
    "#{year}-#{month}-#{day}"
  end

  def days_until_end
    term_end.to_date.yday - Date.today.yday
  end
end

