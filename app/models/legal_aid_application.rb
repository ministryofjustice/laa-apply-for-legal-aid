class LegalAidApplication < ApplicationRecord
  belongs_to :applicant, optional: true
  has_many :application_proceeding_types
  has_many :proceeding_types, through: :application_proceeding_types

  before_create :create_app_ref

  private

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end
end
