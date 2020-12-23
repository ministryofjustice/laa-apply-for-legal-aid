class CashTransaction < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :transaction_type
end
