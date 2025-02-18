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
    quick: 1,
    moderate: 2,
    neither_too_much_nor_too_little: 3,
    alot: 4,
    great_deal: 5,
  }

  validates :satisfaction, :difficulty, presence: true

  validates :done_all_needed, inclusion: { in: [true, false] }
end
