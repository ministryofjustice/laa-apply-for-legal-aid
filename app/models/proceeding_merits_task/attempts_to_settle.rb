module ProceedingMeritsTask
  class AttemptsToSettle < ApplicationRecord
    belongs_to :application_proceeding_type
    belongs_to :proceeding
  end
end
