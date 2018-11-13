class BankError < ApplicationRecord
  belongs_to :bank_provider, optional: true
  belongs_to :applicant
end
