module ProceedingMeritsTask
  class AttemptsToSettle < ApplicationRecord
    self.ignored_columns += %w[application_proceeding_type_id]

    belongs_to :proceeding
  end
end
