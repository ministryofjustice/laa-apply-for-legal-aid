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
    great_deal: 0,
    alot: 1,
    neither_too_much_nor_too_little: 2,
    moderate: 3,
    quick: 4,
  }

  validates :done_all_needed, inclusion: { in: [true, false] }
  validates :difficulty, :satisfaction, presence: true

  validates :contact_name, presence: true, unless: ->(feedback) { feedback.contact_email.blank? }
  validates :contact_email, presence: true, unless: ->(feedback) { feedback.contact_name.blank? }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
