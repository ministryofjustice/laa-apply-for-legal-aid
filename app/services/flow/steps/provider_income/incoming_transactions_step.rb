module Flow
  module Steps
    module ProviderIncome
      IncomingTransactionsStep = Step.new(
        path: ->(application, params) { Steps.urls.providers_legal_aid_application_incoming_transactions_path(application, params.slice(:transaction_type)) },
        forward: :income_summary,
      )
    end
  end
end
