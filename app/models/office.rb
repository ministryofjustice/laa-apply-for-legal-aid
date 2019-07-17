class Office < ApplicationRecord
  has_many :providers
  has_many :legal_aid_applications

  belongs_to :firm
end
