class ServiceLevel < ApplicationRecord
  validates :service_id, :name, presence: true

  def self.populate
    ServiceLevelPopulator.call
  end
end
