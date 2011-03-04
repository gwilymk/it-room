class ValidDateValidator < ActiveModel::EachValidator
  include ApplicationHelper

  def validate_each record, attribute, value
    unless Date.today <= record.date && record.date <= TermDate.term_for(Date.today).term_end
      record.errors.add attribute, I18n.t('activerecord.errors.messages.invalid_date')
    end
  end
end

class ValidSpaceValidator < ActiveModel::EachValidator
  include ApplicationHelper

  def validate_each record, attribute, value
    unless record.room.number_remaining(record.date, record.lesson_number) >= record.number_of_computers
      record.errors.add attribute, I18n.t('activerecord.errors.messages.no_space')
    end
  end
end

class Booking < ActiveRecord::Base
  LESSON_NUMBERS = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5], ['6', 6]]

  belongs_to :user
  belongs_to :room

  validates :user, :presence => true
  validates :date, :presence => true, :valid_date => true
  validates :number_of_computers, :presence => true
  validates :room, :presence => true, :valid_space => true
  validates :lesson_number, :presence => true, :inclusion => {:in => LESSON_NUMBERS.map{|disp,val| val}}
end

