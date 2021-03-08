class DWPOverride < ApplicationRecord
  belongs_to :legal_aid_application

  validates :passporting_benefit, :evidence_available, presence: true
end
