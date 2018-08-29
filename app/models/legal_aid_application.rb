class LegalAidApplication < ApplicationRecord
  belongs_to :applicant, optional: true
  has_many :application_proceedings
  has_many :proceedings, through: :application_proceedings

  before_create :create_app_ref

  private

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end
end
