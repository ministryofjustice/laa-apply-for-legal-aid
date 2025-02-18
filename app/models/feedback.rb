class Feedback < ApplicationRecord
  enum :satisfaction, {
    very_dissatisfied: 0,
    dissatisfied: 1,
    neither_dissatisfied_nor_satisfied: 2,
    satisfied: 3,
    very_satisfied: 4,
  }

  enum :difficulty, {
    very_difficult: 0,
    difficult: 1,
    neither_difficult_nor_easy: 2,
    easy: 3,
    very_easy: 4,
  }

  enum :time_taken_satisfaction, {
    unable: 0,
    great_deal: 1,
    alot: 2,
    neither_too_much_nor_too_little: 3,
    moderate: 4,
    quick: 5,
  }

  validates :satisfaction, :difficulty, presence: true
  validates :done_all_needed, inclusion: { in: [true, false] }

  validates :contact_name, presence: true, unless: ->(feedback) { feedback.contact_email.blank? }
  validates :contact_email, presence: true, unless: ->(feedback) { feedback.contact_name.blank? }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
