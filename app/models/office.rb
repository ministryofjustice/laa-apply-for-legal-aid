class Office < ApplicationRecord
  belongs_to :firm
  has_many :legal_aid_applications
  has_and_belongs_to_many :providers
  has_many :contracts
end
