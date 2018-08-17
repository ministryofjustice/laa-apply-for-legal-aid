class LegalAidApplication < ApplicationRecord
  before_create :create_app_ref

  private

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end
end
