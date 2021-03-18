module ProceedingMeritsTask
  class AttemptsToSettle < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
