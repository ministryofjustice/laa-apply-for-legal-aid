module ProceedingMeritsTask
  class ProhibitedSteps < ApplicationRecord
    self.ignored_columns += %w[confirmed_not_change_of_name]

    belongs_to :proceeding
  end
end
