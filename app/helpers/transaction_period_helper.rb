module TransactionPeriodHelper
  def date_from(application)
    return unless application.transaction_period_start_on

    l(application.transaction_period_start_on.to_date, format: :long_date)
  end

  def date_to(application)
    return unless application.transaction_period_finish_on

    l(application.transaction_period_finish_on.to_date, format: :long_date)
  end
end
