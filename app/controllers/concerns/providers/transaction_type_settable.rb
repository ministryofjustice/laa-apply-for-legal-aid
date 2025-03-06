module Providers
  module TransactionTypeSettable
    extend ActiveSupport::Concern

    included do
      before_action :set_transaction_types
    end

  private

    def set_transaction_types
      @credit_transaction_types = if legal_aid_application.client_uploading_bank_statements?
                                    TransactionType.credits.without_disregarded_benefits.without_benefits
                                  else
                                    TransactionType.credits.without_housing_benefits
                                  end

      @debit_transaction_types = TransactionType.debits
    end
  end
end
