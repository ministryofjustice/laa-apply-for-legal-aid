class Feedback < ApplicationRecord
  include TranslatableModelAttribute

  enum satisfaction: {
    very_dissatisfied: 0,
    dissatisfied: 1,
    neither_dissatisfied_nor_satisfied: 2,
    satisfied: 3,
    very_satisfied: 4
  }

  enum difficulty: {
    very_difficult: 0,
    difficult: 1,
    neither_difficult_nor_easy: 2,
    easy: 3,
    very_easy: 4
  }

  validates :satisfaction, :difficulty, presence: true

  validates :done_all_needed, inclusion: { in: [true, false] }

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.feedback_created', feedback_id: id
  end
end
