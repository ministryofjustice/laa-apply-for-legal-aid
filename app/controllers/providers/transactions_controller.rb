module Providers
  class TransactionsController < ProviderBaseController
    def show
      if transaction_type.name == 'excluded_benefits'
        redirect_to(problem_index_path) && return unless disregarded_state_benefits_list
      end
      transaction_type
      bank_transactions
    end

    def update
      set_selection
      continue_or_draft
    end

    private

    def set_selection
      new_values = { transaction_type_id: transaction_type.id }
      new_values[:meta_data] = manually_chosen_metadata(transaction_type)
      bank_transactions
        .where(id: selected_transaction_ids, meta_data: nil)
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
      benefits_list = state_benefit_types
      return false unless benefits_list

      disregarded_state_benefits = benefits_list.select! { |benefit| benefit['exclude_from_gross_income'] == true }
      categorised_benefits = disregarded_state_benefits.group_by { |benefit| benefit['category'] }
      categorised_benefits.delete(nil)
      @categorised_benefits = categorised_benefits.sort_by { |key, _value| key }
    end

    def state_benefit_types
      CFE::ObtainStateBenefitTypesService.call
    rescue StandardError => e
      Sentry.capture_exception(e)
      false
    end

    def manually_chosen_metadata(transaction_type)
      {
        code: 'XXXX',
        label: 'manually_chosen',
        name: transaction_type.name.titleize,
        category: sentencize(transaction_type.name),
        selected_by: 'Provider'
      }
    end

    def sentencize(sentence)
      sentence.split('_').map(&:capitalize).join(' ')
    end
  end
end
