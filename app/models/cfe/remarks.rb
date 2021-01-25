module CFE
  class Remarks
    REASONS_WITHOUT_CATEGORIES = %i[residual_balance multi_benefit].freeze

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
        break if reason_hashes.is_a?(Array)

        reason_hashes.each do |reason, tx_ids|
          tx_ids.each { |tx_id| collection.update(tx_id, category, reason) }
        end
      end
      collection
    end

    def populate_review_reasons
      reasons = []
      @hash.each do |category, reason_hashes|
        reasons += case reason_hashes
                   when Array
                     reasons << category
                   else
                     reason_hashes.keys
                   end
      end
      reasons.flatten.uniq.sort
    end

    def populate_review_categories_by_reason
      result = Hash.new([])
      @hash.each do |category, reason_hash|
        case reason_hash
        when Array
          reason_hash.each { |reason| result[category] += [reason.to_sym] unless REASONS_WITHOUT_CATEGORIES.include? reason }
        else
          reason_hash.each_key { |reason| result[reason] += [category] unless REASONS_WITHOUT_CATEGORIES.include? reason }
        end
      end
      result
    end
  end
end
