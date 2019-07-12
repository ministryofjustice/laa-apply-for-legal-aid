class Firm < ApplicationRecord
  has_many :offices
  has_many :providers
end
