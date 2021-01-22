class ServiceLevel < ApplicationRecord
  has_many :proceeding_types, dependent: :destroy
  validates :service_level_number, :name, presence: true

  def self.populate
    ServiceLevelPopulator.call
  end
end
