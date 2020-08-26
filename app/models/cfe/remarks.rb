module CFE
  class Remarks
    REASONS_WITHOUT_CATEGORIES = [:residual_balance].freeze

    def initialize(hash)
      @hash = hash
    end

    def caseworker_review_required?
      @hash.present?
    end

    def review_reasons
      @review_reasons ||= populate_review_reasons
    end

    def review_categories_by_reason
      @review_categories_by_reason ||= populate_review_categories_by_reason
    end

    def review_transactions
      @review_transactions ||= populate_review_transactions
    end

    private

    def populate_review_transactions
      collection = RemarkedTransactionCollection.new
      @hash.each do |category, reason_hashes|
        reason_hashes.each do |reason, tx_ids|
          tx_ids.each { |tx_id| collection.update(tx_id, category, reason) }
        end
      end
      collection
    end

    def populate_review_reasons
      reasons = []
      @hash.each do |_category, reason_hashes|
        reasons += reason_hashes.keys
      end
      reasons.flatten.uniq.sort
    end

    def populate_review_categories_by_reason
      result = Hash.new([])
      @hash.each do |category, reason_hash|
        reason_hash.each_key do |reason|
          result[reason] += [category] unless REASONS_WITHOUT_CATEGORIES.include? reason
        end
      end
      result
    end
  end
end
