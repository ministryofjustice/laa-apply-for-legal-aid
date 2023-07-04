class Employment < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :owner, polymorphic: true
  has_many :employment_payments, dependent: :destroy
end
