class ServiceLevel < ApplicationRecord
  validates :service_level_number, :name, presence: true

  def self.populate
    ServiceLevelPopulator.call
  end
end
