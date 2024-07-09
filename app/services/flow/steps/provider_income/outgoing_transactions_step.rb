module Flow
  module Steps
    module ProviderIncome
      OutgoingTransactionsStep = Step.new(
        path: ->(application, params) { Steps.urls.providers_legal_aid_application_outgoing_transactions_path(application, params.slice(:transaction_type)) },
        forward: :outgoings_summary,
      )
    end
  end
end
