module Providers
  class TransactionsController < ProviderBaseController
    def show
      disregarded_state_benefit_list
      disregarded_low_income_benefits
      disregarded_carer_benefits
      disregarded_other_benefits
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

    def disregarded_state_benefit_list
      result = []
      benefits_list = CFE::ObtainStateBenefitTypesService.call
      disregarded_benefits_list = benefits_list.select! { |benefit| benefit['exclude_from_gross_income'] == true }
      disregarded_benefits_list.sort_by! { |item| item['label'] }

      disregarded_benefits_list.each do |state|
        result << { name: state['label'], category: state['category'] }
      end
      @state_benefit_names = result
    end

    def disregarded_low_income_benefits
      result = []
      #benefits_list = CFE::ObtainStateBenefitTypesService.call
      @disregarded_benefits_list = benefits_list.select! { |benefit| benefit['category'] == 'low_income' }
      @disregarded_benefits_list.sort_by! { |item| item['label'] }

      @disregarded_benefits_list.each do |state|
        result << { name: state['label'], category: state['category'] }
      end
      @low_income_benefits = result
    end

    def disregarded_carer_benefits
      result = []
      benefits_list = CFE::ObtainStateBenefitTypesService.call
      @disregarded_benefits_list = benefits_list.select! { |benefit| benefit['category'] == 'carer_disability' }
      @disregarded_benefits_list.sort_by! { |item| item['label'] }

      @disregarded_benefits_list.each do |state|
        result << { name: state['label'], category: state['category'] }
      end
      @carer_benefits = result
    end

    def disregarded_other_benefits
      result = []
      benefits_list = CFE::ObtainStateBenefitTypesService.call
      @disregarded_benefits_list = benefits_list.select! { |benefit| benefit['category'] == 'other' }
      @disregarded_benefits_list.sort_by! { |item| item['label'] }

      @disregarded_benefits_list.each do |state|
        result << { name: state['label'], category: state['category'] }
      end
      @other_benefits = result
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
