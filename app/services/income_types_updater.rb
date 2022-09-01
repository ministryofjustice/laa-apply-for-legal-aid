class IncomeTypesUpdater
  include Providers::Draftable
  include TransactionTypesUpdateable

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def save
    synchronize_credit_transaction_types

    if none_selected?
      legal_aid_application.update!(no_credit_transaction_types_selected: true)

      return true
    elsif transaction_types_selected?
      legal_aid_application.update!(no_credit_transaction_types_selected: false)

      return true
    end

    return true if draft_selected?

    false
  end

private

  def transaction_types
    @transaction_types ||= TransactionType.credits.find_with_children(legal_aid_application_params[:transaction_type_ids])
  end

  def synchronize_credit_transaction_types
    existing_credit_tt_ids = legal_aid_application.legal_aid_application_transaction_types.credits.map(&:transaction_type_id)

    keep = transaction_types.each_with_object([]) do |form_tt, arr|
      add_transaction_type(form_tt) if existing_credit_tt_ids.exclude?(form_tt.id)
      arr.append(form_tt.id)
    end

    destroy_all_credit_transaction_types(except: keep)
  end

  def destroy_all_credit_transaction_types(except:)
    LegalAidApplication.transaction do
      legal_aid_application
        .legal_aid_application_transaction_types
        .credits
        .where.not(transaction_type_id: except)
        .destroy_all
    end
  end
end
