module CFE
  class RemarkedTransaction
    attr_reader :tx_id, :category

    def initialize(tx_id, category, reason)
      @tx_id = tx_id
      @category = category
      @reasons = [reason]
    end

    def update(tx_id, category, reason)
      raise ArgumentError, 'Transaction Id mismatch' unless tx_id == @tx_id

      raise ArgumentError, 'Category mismatch' unless category == @category

      @reasons << reason
    end

    def reasons
      @reasons.uniq.sort
    end
  end
end
