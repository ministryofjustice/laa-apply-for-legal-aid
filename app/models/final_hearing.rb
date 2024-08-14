class FinalHearing < ApplicationRecord
  belongs_to :proceeding

  enum :work_type, { substantive: 0, emergency: 1 }
  scope :emergency, -> { where(work_type: :emergency) }
  scope :substantive, -> { where(work_type: :substantive) }
end
