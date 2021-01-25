class CfeApiDisplayer
  def initialize(application_ref)
    @legal_aid_application = LegalAidApplication.find_by(application_ref: application_ref)
  end

  def run
    display_bank_transactions
    display_cfe_submission_history
  end

  private

  def categorised_bank_transactions
    @categorised_bank_transactions ||= @legal_aid_application.bank_transactions.by_type
  end

  def cfe_submission
    @cfe_submission ||= @legal_aid_application.most_recent_cfe_submission
  end

  def cfe_submission_histories
    cfe_submission.submission_histories.order(:created_at)
  end

  def display_bank_transactions
    logger.info '>>>> BANK TRANSACTIONS <<<<'
    categorised_bank_transactions.each do |transaction_type, txs|
      logger.info "#{transaction_type.name}:"
      txs.each do |tx|
        logger.info format('   %<date>s %<amount>.2f %<description>s',
                           date: tx.happened_at.strftime('%F'),
                           amount: tx.amount,
                           description: tx.description)
      end
    end
  end

  def display_cfe_submission_history
    logger.info "\n>>>>>  CFE SUBMISSION <<<<"
    cfe_submission_histories.each { |history| display_history(history) }
  end

  def display_history(history)
    logger.info "#{history.http_method} #{history.url}"
    logger.info JSON.parse(history.request_payload) if history.http_method == 'POST'
    logger.info JSON.parse(history.response_payload)
    logger.info '++++++++++++++++++++++++++++++++++++++++++++'
  end

  def logger
    Rails.logger
  end
end
