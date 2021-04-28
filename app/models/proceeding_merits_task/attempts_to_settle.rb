module ProceedingMeritsTask
  class AttemptsToSettle < ApplicationRecord
    belongs_to :application_proceeding_type
  end
end
