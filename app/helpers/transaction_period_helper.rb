module TransactionPeriodHelper
  def date_from
    return unless @legal_aid_application.transaction_period_start_on

    l(@legal_aid_application.transaction_period_start_on.to_date, format: :long_date)
  end

  def date_to
    return unless @legal_aid_application.transaction_period_finish_on

    l(@legal_aid_application.transaction_period_finish_on.to_date, format: :long_date)
  end
end
