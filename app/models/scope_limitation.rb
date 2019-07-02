class ScopeLimitation < ApplicationRecord
  validates :code, :meaning, :description, presence: true
  validates :substantive, :delegated_functions, inclusion: [true, false]

  def self.populate
    ScopeLimitationsPopulator.call
  end
end
