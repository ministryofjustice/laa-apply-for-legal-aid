module Providers
  class TransactionsController < ProviderBaseController
    def show
      disregarded_state_benefits_list
      transaction_type
      bank_transactions
    end

    def update
      reset_selection
      set_selection
      continue_or_draft
    end

    private

    def reset_selection
      bank_transactions.where(transaction_type_id: transaction_type.id).update_all(transaction_type_id: nil)
    end

    def set_selection
      new_values = { transaction_type_id: transaction_type.id }
      new_values[:meta_data] = manually_chosen_metadata if any_type_of_benefit?(transaction_type)
      bank_transactions
        .where(id: selected_transaction_ids)
        .update_all(new_values)
    end

    def selected_transaction_ids
      params[:transaction_ids].select(&:present?)
    end

    def transaction_type
      @transaction_type ||= TransactionType.find_by(name: params[:transaction_type]) || TransactionType.first
    end

    def bank_transactions
      @bank_transactions ||=
        legal_aid_application
        .bank_transactions
        .where(operation: transaction_type.operation)
        .order(happened_at: :desc, description: :desc)
    end

    def disregarded_state_benefits_list
      benefits_list = CFE::ObtainStateBenefitTypesService.call
      disregarded_state_benefits = benefits_list.select! { |benefit| benefit['exclude_from_gross_income'] == true }
      categorised_benefits = disregarded_state_benefits.group_by { |benefit| benefit['category'] }
      categorised_benefits.delete(nil)
      @categorised_benefits = categorised_benefits.sort_by { |key, _value| key }
    end

    def manually_chosen_metadata
      {
        code: 'XXXX',
        label: 'manually_chosen',
        name: 'Manually chosen'
      }
    end

    def any_type_of_benefit?(transaction_type)
      transaction_type.name.in?(TransactionType.any_type_of('benefits').map(&:name))
    end
  end
end
