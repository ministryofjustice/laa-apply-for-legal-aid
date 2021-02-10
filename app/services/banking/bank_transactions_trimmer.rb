module Banking
  class BankTransactionsTrimmer
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      deletion_period = (@legal_aid_application.transaction_period_finish_on..1.year.from_now)
      @legal_aid_application.bank_transactions
                            .where(happened_at: deletion_period)
                            .destroy_all
    end
  end
end
