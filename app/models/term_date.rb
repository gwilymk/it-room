# == Schema Information
# Schema version: 20110228145452
#
# Table name: term_dates
#
#  id         :integer         not null, primary key
#  term_begin :date
#  term_end   :date
#  week_start :integer
#  created_at :datetime
#  updated_at :datetime
#
# This model is for storing term_dates. They are stored as the start date, the end date and the week
# the term starts with.
#
class TermDate < ActiveRecord::Base
  validates :week_start, :presence => true, :numericality => {:only_integer => true}, :inclusion => {:in => 1..2, :message => "Week must be 1 or 2"}
  validates :term_begin, :date => true, :format => /\d{2}\/\d{2}\/\d{4}/
  validates :term_end, :date => true, :format => /\d{2}\/\d{2}\/\d{4}/

  before_destroy do
    Booking.where("date >= ? AND date <= ?", self.term_begin, self.term_end).destroy_all
  end

  # This returns a new empty term with the start and end today and the week starting with 1.
  # This is mainly used to stop jQuery-ui from crashing and also in term_for
  def self.default_term
    TermDate.new(:term_begin => Date.today, :term_end => Date.today, :week_start => 1)
  end

  # Works out the term_for the date given.
  #
  # date _date_ defaults to today
  def self.term_for date = Date.today
    term = nil

    # get the date as a date object
    date = date.to_date

    # go through every term_date
    self.all.each do |td|
      # if the date is within the term_beginning and the term_end set
      # term to that
      term = td if td.term_begin <= date && date <= td.term_end
    end

    # if there is no term, return the default one
    term || TermDate.default_term
  end

  # Works out the last term in terms of date or returns the default term
  def self.last_term
    # if the term date isn't fount, return the default one
    TermDate.order('term_end ASC').last || TermDate.default_term
  end

  # Returns the current week number for date _date_
  def self.week date = Date.today
    week_number = 1

    # Find out which term the date is in.
    term = term_for date

    # if the date isn't within a term, return 0
    return 0 unless term

    # Find out which week it is by alternting weeks starting with the first week in the current term.
    cweek = date.to_date.cweek
    cweek_term = term.term_begin.to_date.cweek

    cweek %= 2 # divide it by 2 and get the remainder
    cweek_term %= 2

    # if the week (by assuming the 1st week is a week 1) is correct,
    # return the week number
    if cweek == cweek_term
      week_number = term.week_start
    else
      if term.week_start == 1
        week_number = 2
      elsif term.week_start == 2 #I don't use else here as week_number = 0 if the date is not during school terms
        week_number = 1
      end
    end

    week_number
  end

  # This works out the number of days until the end of term.
  def self.days_until_end
    term = term_for Date.today

    # find the day integer (0-365) and subract it from the integer of today,
    # this will give the number of days lft until the end of term.
    term.term_end.to_date.yday - Date.today.yday
  end
end

