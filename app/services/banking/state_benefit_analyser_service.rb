module Banking
  class StateBenefitAnalyserService
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @benefit_transactions_found = false
      @legal_aid_application = legal_aid_application
    end

    def call
      @legal_aid_application.bank_transactions.credit.each { |txn| process_transaction(txn) }
      update_legal_aid_transaction_types if @benefit_transactions_found
    end

  private

    def included_benefit_transaction_type
      @included_benefit_transaction_type ||= TransactionType.find_by(name: "benefits")
    end

    def process_transaction(txn)
      identify_state_benefit(txn) if state_benefit_payment_pattern?(txn.description)
    end

    def identify_state_benefit(txn)
      matches = txn.description.scan(regex_pattern).uniq
      if matches.count > 1
        process_multiple_benefits(txn)
      else
        @benefit_transactions_found = true
        dwp_code = matches.flatten.first
        benefit = state_benefit_types[dwp_code]
        process_known_benefit(txn, benefit)
      end
    end

    def process_multiple_benefits(txn)
      txn.update!(transaction_type: included_benefit_transaction_type, meta_data: multi_dwp_codes_meta_data, flags: { multi_benefit: true })
    end

    def multi_dwp_codes_meta_data
      {
        code: "multiple",
        label: "multiple dwp codes",
        name: "multiple state benefits",
        selected_by: "System",
      }
    end

    def process_known_benefit(txn, benefit)
      return if benefit.excluded?

      txn.update!(transaction_type: included_benefit_transaction_type, meta_data: known_meta(benefit))
    end

    def known_meta(benefit)
      {
        code: benefit.code,
        label: benefit.label,
        name: benefit.name,
        selected_by: "System",
      }
    end

    def state_benefit_payment_pattern?(description)
      regex_pattern.match?(description)
    end

    def regex_pattern
      @regex_pattern ||= /\b(#{keys})\b/
    end

    def keys
      @keys ||= state_benefit_types.keys.join("|").gsub("\\", "\\\\").gsub("/", '\/')
    end

    def update_legal_aid_transaction_types
      @legal_aid_application.transaction_types << included_benefit_transaction_type unless @legal_aid_application.transaction_types.include?(included_benefit_transaction_type)
      @legal_aid_application.save!
    end

    def state_benefit_types
      @state_benefit_types ||= Banking::StateBenefitsLoader.call
    end
  end
end
