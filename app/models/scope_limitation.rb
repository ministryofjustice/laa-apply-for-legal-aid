class ScopeLimitation < ApplicationRecord
  has_many :proceeding_type_scope_limitations
  has_many :proceeding_types, through: :proceeding_type_scope_limitations

  validates :code, :meaning, :description, presence: true
  validates :substantive, :delegated_functions, inclusion: [true, false]

  def self.populate
    ScopeLimitationsPopulator.call
  end
end
