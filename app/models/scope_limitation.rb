class ScopeLimitation < ApplicationRecord
  belongs_to :proceeding

  enum scope_type: { substantive: 0, emergency: 1 }
  scope :emergency, -> { where(scope_type: :emergency) }
  scope :substantive, -> { where(scope_type: :substantive) }
end
