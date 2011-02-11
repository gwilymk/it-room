class TermDate < ActiveRecord::Base
  validates :week_start, :presence => true, :numericality => {:only_integer => true}, :inclusion => {:in => 1..2, :message => "Week must be 1 or 2"}
  validates :term_begin, :date => true
  validates :term_end, :date => true

  def self.default_term
    TermDate.new(:term_begin => Date.today, :term_end => Date.today, :week_start => 1)
  end

  def self.term_for date = Date.today
    term = nil

    date = date.to_date

    self.all.each do |td|
      term = td if td.term_begin < date && date < td.term_end
    end

    term || TermDate.default_term
  end

  def self.last_term
    TermDate.order('term_end').last || TermDate.default_term
  end

  # Returns the current week number for date _date_
  def self.week date = Date.today
    week_number = 1

    # Find out which term the date is in.
    term = term_for date

    return 0 unless term

    # Find out which week it is by alternting weeks starting with the first week in the current term.
    cweek = date.to_date.cweek
    cweek_term = term.term_begin.to_date.cweek

    cweek %= 2
    cweek_term %= 2

    if cweek == cweek_term
      week_number = term.week_start
    else
      if term.week_start == 1
        week_number = 2
      elsif term.week_start == 2 #I don't use else here as week_number = 0 if the the ate is not during school terms
        week_number = 1
      end
    end

    week_number
  end

  def self.days_until_end
    term = term_for Date.today

    term.term_end.to_date.yday - Date.today.yday
  end
end

