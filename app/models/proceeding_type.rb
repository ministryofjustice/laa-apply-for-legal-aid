class ProceedingType < ApplicationRecord
  has_many :application_proceeding_types
  has_many :legal_aid_applications, through: :application_proceeding_types
  has_many :proceeding_type_scope_limitations
  has_many :scope_limitations, through: :proceeding_type_scope_limitations
  belongs_to :default_level_of_service, class_name: 'ServiceLevel', foreign_key: 'default_service_level_id'

  validates :code, presence: true

  def self.populate
    ProceedingTypePopulator.call
  end

  def default_substantive_scope_limitation
    proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation
  end

  def default_delegated_functions_scope_limitation
    proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation
  end
end
