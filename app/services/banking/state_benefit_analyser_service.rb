module Banking
  class StateBenefitAnalyserService
    Struct.new('Benefit', :code, :label, :name, :excluded?)

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def initialize(legal_aid_application)
      @benefit_transactions_found = false
      @legal_aid_application = legal_aid_application
      @state_benefit_codes = {}
    end

    def call
      load_state_benefit_types
      @legal_aid_application.bank_transactions.credit.each { |txn| process_transaction(txn) }
      update_legal_aid_transaction_types if @benefit_transactions_found
    end

    private

    def included_benefit_transaction_type
      @included_benefit_transaction_type ||= TransactionType.find_by(name: 'benefits')
    end

    def excluded_benefit_transaction_type
      @excluded_benefit_transaction_type ||= TransactionType.find_by(name: 'excluded_benefits')
    end

    def process_transaction(txn)
      identify_state_benefit(txn) if state_benefit_payment_pattern?(txn.description)
    end

    def load_state_benefit_types
      state_benefit_list = CFE::ObtainStateBenefitTypesService.call
      state_benefit_list.each do |sb_hash|
        next if sb_hash['dwp_code'].nil?

        store_benefit(sb_hash)
      end
    end

    def store_benefit(sb_hash)
      benefit = Struct::Benefit.new(sb_hash['dwp_code'], sb_hash['label'], sb_hash['name'], sb_hash['exclude_from_gross_income'])
      @state_benefit_codes[benefit.code] = benefit
    end

    def identify_state_benefit(txn)
      matches = txn.description.scan(regex_pattern).uniq
      if matches.count > 1
        process_multiple_benefits(txn)
      else
        @benefit_transactions_found = true
        dwp_code = matches.flatten.first
        benefit = @state_benefit_codes[dwp_code]
        process_known_benefit(txn, benefit)
      end
    end

    def process_multiple_benefits(txn)
      txn.update!(transaction_type: included_benefit_transaction_type, meta_data: multi_dwp_codes_meta_data, flags: { multi_benefit: true })
    end

    def multi_dwp_codes_meta_data
      {
        code: 'multiple',
        label: 'multiple dwp codes',
        name: 'multiple state benefits',
        selected_by: 'System'
      }
    end

    def process_known_benefit(txn, benefit)
      transaction_type = benefit.excluded? ? excluded_benefit_transaction_type : included_benefit_transaction_type
      txn.update!(transaction_type: transaction_type, meta_data: known_meta(benefit))
    end

    def known_meta(benefit)
      {
        code: benefit.code,
        label: benefit.label,
        name: benefit.name,
        selected_by: 'System'
      }
    end

    def state_benefit_payment_pattern?(description)
      regex_pattern.match?(description)
    end

    def regex_pattern
      @regex_pattern ||= Regexp.new(/\b(#{keys})\b/)
    end

    def keys
      @keys ||= @state_benefit_codes.keys.join('|').gsub('/', '\/')
    end

    def update_legal_aid_transaction_types
      [included_benefit_transaction_type, excluded_benefit_transaction_type].each do |tt|
        @legal_aid_application.transaction_types << tt unless @legal_aid_application.transaction_types.include?(tt)
      end
      @legal_aid_application.save!
    end
  end
end
