class ProceedingType < ApplicationRecord
  has_many :application_proceeding_types
  has_many :legal_aid_applications, through: :application_proceeding_types
  has_many :proceeding_type_scope_limitations
  has_many :scope_limitations, through: :proceeding_type_scope_limitations
  belongs_to :default_level_of_service, class_name: 'ServiceLevel', foreign_key: 'default_service_level_id'

  validates :code, presence: true

  scope :with_ccms_code_starting, ->(_text) do
    where(arel_table[:ccms_code].matches_regexp('^DA\d+$'))
  end

  def self.populate
    ProceedingTypePopulator.call
  end
end
