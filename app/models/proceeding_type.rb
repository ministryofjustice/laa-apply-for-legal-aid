class ProceedingType < ApplicationRecord
  has_many :application_proceeding_types
  has_many :legal_aid_applications, through: :application_proceeding_types

  validates :code, presence: true

  scope :with_ccms_code_starting, ->(text) do
    where(arel_table[:ccms_code].matches("#{text}%"))
  end

  # scope :with_ccms_code_regex, ->(text) do
  #   where(arel_table[:ccms_code]=~("#{text}%")
  # end

  scope :with_proceeding_code_number, ->(text) do
    where(arel_table)[:code].matches("#{text}%")
  end

end
