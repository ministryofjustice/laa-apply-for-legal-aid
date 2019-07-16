class ProceedingTypeScopeLimitation < ApplicationRecord
  belongs_to :proceeding_type
  belongs_to :scope_limitation

  def self.populate
    ProceedingTypeScopeLimitationsPopulator.call
  end
end
