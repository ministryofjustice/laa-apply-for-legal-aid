class ScopeLimitation < ApplicationRecord
  validates :code, :meaning, :description, presence: true
  validates :substantive, :delegated_functions, inclusion: [true, false]
end
