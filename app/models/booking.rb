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
  belongs_to :user
  belongs_to :room

  validates :user, :presence => true
  validates :number_of_computers, :presence => true
  validates :room, :presence => true, :valid_space => true
  validates :date, :presence => true, :valid_date => true

  LESSON_NUMBERS = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5], ['6', 6]]
end

