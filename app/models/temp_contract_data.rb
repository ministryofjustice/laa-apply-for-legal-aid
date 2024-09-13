class TempContractData < ApplicationRecord
  validates :office_code, :response, presence: true
end
