module TransactionTypeHelper
  def answer_for_transaction_type(legal_aid_application:, transaction_type:)
    total = legal_aid_application.transactions_total_by_category(transaction_type.id)
    has_transaction_type = legal_aid_application.has_transaction_type?(transaction_type)

    if has_transaction_type && total.zero?
      legal_aid_application.client_uploading_bank_statements? ? t("generic.yes") : t("generic.yes_but_none")
    elsif has_transaction_type && total.positive?
      legal_aid_application.client_uploading_bank_statements? ? t("generic.yes") : number_to_currency(total)
    else
      t("generic.none")
    end
  end

  def regular_transaction_answer_by_type(legal_aid_application:, transaction_type:, owner_type:)
    regular_transaction = legal_aid_application.regular_transactions.find_by(transaction_type:, owner_type:)
    if regular_transaction
      [number_to_currency(regular_transaction.amount), t("transaction_types.frequencies.#{regular_transaction.frequency}")]
    else
      t("generic.none")
    end
  end
end
