class ProceedingTypeScopeLimitation < ApplicationRecord
  belongs_to :proceeding_type
  belongs_to :scope_limitation
  validates_uniqueness_of :proceeding_type_id, scope: :scope_limitation_id
  validates_uniqueness_of :proceeding_type_id, conditions: -> { where(substantive_default: true) }, scope: :substantive_default
  validates_uniqueness_of :proceeding_type_id, conditions: -> { where(delegated_functions_default: true) }, scope: :delegated_functions_default

  def self.populate
    ProceedingTypeScopeLimitationsPopulator.call
  end
end
