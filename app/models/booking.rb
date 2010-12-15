class ValidDateValidator < ActiveModel::EachValidator
  include ApplicationHelper

  def validate_each record, attribute, value
    unless Date.today <= record.date && record.date <= term_end
      record.errors.add attr, "Has an invalid date"
    end
  end
end

class Booking < ActiveRecord::Base
  belongs_to :user, :dependent => :delete
  belongs_to :room, :dependent => :delete

  validates :user, :presence => true
  validates :room, :presence => true
  validates :date, :presence => true, :valid_date => true

  LESSON_NUMBERS = [["1", 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5], ['6', 6]]
end

