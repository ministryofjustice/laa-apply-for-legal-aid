module CFE
  class RemarkedTransactionCollection
    attr_reader :transactions

    def initialize
      @transactions = {}
    end

    def update(tx_id, category, reason)
      if @transactions.key?(tx_id)
        @transactions[tx_id].update(tx_id, category, reason)
      else
        @transactions[tx_id] = RemarkedTransaction.new(tx_id, category, reason)
      end
    end
  end
end
