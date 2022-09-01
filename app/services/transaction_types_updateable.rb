module TransactionTypesUpdateable
  def legal_aid_application
    @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
  end

  def legal_aid_application_params
    params.require(:legal_aid_application).permit(transaction_type_ids: [])
  end

  def transaction_types_selected?
    transaction_types.present?
  end

  def none_selected?
    params[:legal_aid_application][:none_selected] == "true"
  end

  def add_transaction_type(transaction_type)
    legal_aid_application.transaction_types << transaction_type
  end
end
