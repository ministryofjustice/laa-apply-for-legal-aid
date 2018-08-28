class LegalAidApplication < ApplicationRecord
  belongs_to :applicant, optional: true
  before_create :create_app_ref

  private

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end
end
