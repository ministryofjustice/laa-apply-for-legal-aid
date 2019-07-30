class ProceedingTypeScopeLimitation < ApplicationRecord
  belongs_to :proceeding_type
  belongs_to :scope_limitation

  def self.default_substantive_scope_limitation
    find_by(substantive_default: true)&.scope_limitation
  end

  def self.default_delegated_functions_scope_limitation
    find_by(delegated_functions_default: true)&.scope_limitation
  end

  def self.populate
    ProceedingTypeScopeLimitationsPopulator.call
  end
end
