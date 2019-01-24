class Feedback < ApplicationRecord
  include TranslatableModelAttribute

  enum satisfaction: {
    very_dissatisfied: 0,
    dissatisfied: 1,
    neither_dissatisfied_nor_satisfied: 2,
    satisfied: 3,
    very_satisfied: 4
  }
end
