class ProceedingType < ApplicationRecord
  has_many :application_proceeding_types
  has_many :legal_aid_applications, through: :application_proceeding_types

  validates :code, presence: true

  scope :with_ccms_code_starting, ->(_text) do
    where(arel_table[:ccms_code].matches_regexp('^DA\d+$'))
  end

  DOMESTIC_ABUSE_CCMS_MATTER_CODE = 'MINJN'.freeze

  def domestic_abuse?
    ccms_matter_code == DOMESTIC_ABUSE_CCMS_MATTER_CODE
  end
end
