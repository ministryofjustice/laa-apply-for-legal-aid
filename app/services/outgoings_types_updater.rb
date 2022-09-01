class OutgoingsTypesUpdater
  include Providers::Draftable

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def save
    synchronize_debit_transaction_types

    if none_selected?
      legal_aid_application.update!(no_debit_transaction_types_selected: true)

      return true
    elsif transaction_types_selected?
      legal_aid_application.update!(no_debit_transaction_types_selected: false)

      return true
    end

    return true if draft_selected?

    false
  end

private

  def legal_aid_application
    @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
  end

  def legal_aid_application_params
    params.require(:legal_aid_application).permit(transaction_type_ids: [])
  end

  def transaction_types
    @transaction_types ||= TransactionType.debits.where(id: legal_aid_application_params[:transaction_type_ids])
  end

  def transaction_types_selected?
    transaction_types.present?
  end

  def none_selected?
    params[:legal_aid_application][:none_selected] == "true"
  end

  def synchronize_debit_transaction_types
    existing_debit_tt_ids = legal_aid_application.legal_aid_application_transaction_types.debits.map(&:transaction_type_id)

    keep = transaction_types.each_with_object([]) do |form_tt, arr|
      add_transaction_type(form_tt) if existing_debit_tt_ids.exclude?(form_tt.id)
      arr.append(form_tt.id)
    end

    destroy_all_debit_transaction_types(except: keep)
  end

  def add_transaction_type(transaction_type)
    legal_aid_application.transaction_types << transaction_type
  end

  def destroy_all_debit_transaction_types(except:)
    LegalAidApplication.transaction do
      legal_aid_application
        .legal_aid_application_transaction_types
        .debits
        .where.not(transaction_type_id: except)
        .destroy_all
    end
  end
end
