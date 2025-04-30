module TransactionTypeHelper
  def answer_for_transaction_type(legal_aid_application:, transaction_type:, owner_type:)
    total = legal_aid_application.transactions_total_by_category(transaction_type.id)
    has_transaction_type = legal_aid_application.has_transaction_type?(transaction_type, owner_type)

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
      [number_to_currency(regular_transaction.amount), t("transaction_types.frequencies.#{regular_transaction.frequency}").downcase]
    else
      t("generic.none")
    end
  end

  def format_transactions(legal_aid_application:, credit_or_debit:, regular_or_cash:, individual:)
    transaction_types(legal_aid_application:, credit_or_debit:).map do |type|
      transactions = transactions_for(legal_aid_application:, credit_or_debit:, regular_or_cash:, individual:)
      {
        label: type.label_name,
        value: transactions[type.name] || t("generic.none"),
      }
    end
  end

  def transactions_for(legal_aid_application:, credit_or_debit:, regular_or_cash:, individual:)
    if regular_or_cash == :regular
      regular_transactions_for(legal_aid_application:, credit_or_debit:, individual:)
    else
      cash_transactions_for(legal_aid_application:, credit_or_debit:, individual:)
    end
  end

  def regular_transactions_for(legal_aid_application:, credit_or_debit:, individual:)
    legal_aid_application.regular_transactions.where(owner_type: individual).send("#{credit_or_debit}s").to_h do |r|
      [
        r.transaction_type.name,
        "#{number_to_currency(r.amount)} #{t("transaction_types.frequencies.#{r.frequency}").downcase}",
      ]
    end
  end

  def cash_transactions_for(legal_aid_application:, credit_or_debit:, individual:)
    transactions = legal_aid_application.cash_transactions.where(owner_type: individual).send("#{credit_or_debit}s").sort_by(&:transaction_date)

    labels = transactions.group_by { |ct| ct.transaction_type.name }.transform_values do |group|
      group.map { |ct|
        t("generic.amount_and_date", amount: gds_number_to_currency(ct.amount, precision: 2), month: ct.transaction_date.strftime("%B %Y"))
      }.join("<br>")
    end

    labels.to_h
  end

  def transaction_types(legal_aid_application:, credit_or_debit:)
    return credit_transaction_types(legal_aid_application:) if credit_or_debit == :credit

    TransactionType.debits
  end

  def credit_transaction_types(legal_aid_application:)
    if legal_aid_application.client_uploading_bank_statements?
      TransactionType.credits.without_disregarded_benefits.without_benefits
    else
      TransactionType.credits.without_housing_benefits
    end
  end
end
