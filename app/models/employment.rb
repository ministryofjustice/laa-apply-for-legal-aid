class Employment < ApplicationRecord
  belongs_to :legal_aid_application
  has_many :employment_payments, dependent: :destroy
end
