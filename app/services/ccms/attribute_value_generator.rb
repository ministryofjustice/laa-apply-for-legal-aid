module CCMS
  # This class is used to generate the Attribute key-value XML block within the instances of the
  # various entities on the CCMS add request payload.  Each possible key value pair has an
  # entry in the attribute configuration hash (created by the CCMS::AttributeConfiguration class from
  # YAML files in the config/ccms/ directory).
  #
  # Each key in the configuration hash file has the following attributes:
  #
  # * generate_block? (optional).  If present, specifies the name of a method to call on this class
  #   to specify whether or not the block should be generated
  # * value: can either be a hard-coded value, or the name of a method to call on this class to supply
  #   the value to insert.
  # * br100_meaning: The definition of this key according to the BR100 spreadsheet (for documentation purposes only)
  # * response_type: The value to insert for the <ResponseType> element in the block
  # * user_defined: The value to insert for the <UserDefined> element in the block
  #
  # Magic method names
  # ==================
  # If the method begins with one of the following prefixes, and is not specifically defined in this class, then the
  # method name without the prefix is called on the appropriate object in the options hash, e.g.
  # 'vehicle_registration_number'  will call the registration_number method on options[:vehicle] in order to get the
  # value to insert.
  class AttributeValueGenerator # rubocop:disable Metrics/ClassLength
    STANDARD_METHOD_NAMES = %r{^(
                                appl_proceeding_type
                                |applicant
                                |application
                                |bank_account
                                |lead_proceeding_type
                                |chances_of_success
                                |opponent
                                |other_assets_declaration
                                |other_party
                                |proceeding
                                |opponent
                                |outgoing
                                |savings_amount
                                |income_type
                                |vehicle
                                |wage_slip
                                )_(\S+)$}x.freeze
    APPLICATION_PROCEEDING_TYPE_REGEX = /^appl_proceeding_type_(\S+)$/.freeze
    APPLICANT_REGEX = /^applicant_(\S+)$/.freeze
    APPLICATION_REGEX = /^application_(\S+)$/.freeze
    BANK_REGEX = /^bank_account_(\S+)$/.freeze
    LEAD_PROCEEDING_TYPE = /^lead_proceeding_type_(\S+)$/.freeze
    CHANCES_OF_SUCCESS = /^chances_of_success_(\S+)$/.freeze
    OPPONENT = /^opponent_(\S+)$/.freeze
    OTHER_ASSETS_DECLARATION = /^other_assets_declaration_(\S+)$/.freeze
    OTHER_PARTY = /^other_party_(\S+)$/.freeze
    PROCEEDING_REGEX = /^proceeding_(\S+)$/.freeze
    SAVINGS_AMOUNT = /^savings_amount_(\S+)$/.freeze
    INCOME_TYPE_REGEX = /^income_type_(\S+)$/.freeze
    VEHICLE_REGEX = /^vehicle_(\S+)$/.freeze
    WAGE_SLIP_REGEX = /^wage_slip_(\S+)$/.freeze
    OUTGOING = /^outgoing_(\S+)$/.freeze

    PROSPECTS_OF_SUCCESS = {
      likely: { text: 'Good', code: 'FM' },
      marginal: { text: 'Marginal', code: 'FO' },
      poor: { text: 'Poor', code: 'NE' },
      borderline: { text: 'Borderline', code: 'FH' },
      uncertain: { text: 'Uncertain', code: 'FJ' },
      not_known: { text: 'Uncertain', code: 'FJ' }
    }.freeze

    attr_reader :legal_aid_application

    delegate :lead_application_proceeding_type,
             :vehicle,
             :used_delegated_functions?, to: :legal_aid_application

    def initialize(submission)
      @legal_aid_application = submission.legal_aid_application
    end

    def method_missing(method, *args)
      if standardly_named_method?(method)
        call_standard_method(method, args.first)
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      standardly_named_method?(method) || super
    end

    def valuable_possessions_aggregate_value(_options)
      other_assets.valuable_items_value
    end

    def bank_name(options)
      options[:bank_acct].bank_provider.name
    end

    def bank_account_holder_type(options)
      options[:bank_acct].holder_type
    end

    def submission_case_ccms_reference(_options)
      legal_aid_application.case_ccms_reference
    end

    def used_delegated_functions_on(_options)
      legal_aid_application.used_delegated_functions_on.strftime('%d-%m-%Y')
    end

    def app_amendment_type(_options)
      legal_aid_application.used_delegated_functions? ? 'SUBDP' : 'SUB'
    end

    def provider_firm_id(_options)
      legal_aid_application.provider.firm.ccms_id
    end

    def provider_email(_options)
      legal_aid_application.provider.email
    end

    def applicant_national_insurance_number(_options)
      applicant.national_insurance_number
    end

    def applicant_owed_money?(_options)
      not_zero? other_assets.money_owed_value
    end

    def applicant_owed_money_value(_options)
      other_assets.money_owed_value
    end

    def applicant_has_interest_in_a_trust?(_options)
      not_zero? other_assets.trust_value
    end

    def applicant_has_valuable_possessions?(_options)
      not_zero? other_assets.valuable_items_value
    end

    def applicant_owns_timeshare?(_options)
      not_zero? other_assets.timeshare_property_value
    end

    def applicant_land_value(_options)
      other_assets.land_value
    end

    def applicant_owns_land?(_options)
      not_zero? other_assets.land_value
    end

    def applicant_has_inheritance?(_options)
      not_zero? other_assets.inherited_assets_value
    end

    def applicant_has_investments?(_options)
      not_zero?(savings.national_savings) ||
        not_zero?(savings.plc_shares) ||
        not_zero?(savings.peps_unit_trusts_capital_bonds_gov_stocks) ||
        not_zero?(savings.life_assurance_endowment_policy)
    end

    def applicant_owns_additional_property?(_options)
      not_zero? other_assets.second_home_value
    end

    def applicant_shares_ownership_of_second_home?(options)
      applicant_owns_additional_property?(options) && legal_aid_application.other_assets_declaration.second_home_percentage != 100
    end

    def applicant_has_trusts_bonds_or_stocks?(_options)
      not_zero? savings.peps_unit_trusts_capital_bonds_gov_stocks
    end

    def applicant_has_other_capital?(_options)
      not_zero? savings.peps_unit_trusts_capital_bonds_gov_stocks
    end

    def applicant_has_national_savings?(_options)
      not_zero? savings.national_savings
    end

    def applicant_has_other_savings?(_options)
      not_zero?(savings.offline_current_accounts) || not_zero?(savings.offline_savings_accounts)
    end

    def applicant_has_other_policies?(_options)
      not_zero? savings.life_assurance_endowment_policy
    end

    def applicant_has_shares?(_options)
      not_zero? savings.plc_shares
    end

    def applicant_is_signatory_to_other_person_accounts?(_options)
      not_zero? savings.other_person_account
    end

    def lead_proceeding_type_default_level_of_service(_options)
      legal_aid_application.lead_proceeding_type.default_level_of_service.service_level_number
    end

    def lead_proceeding_type_default_level_of_service_name(_options)
      legal_aid_application.lead_proceeding_type.default_level_of_service.name
    end

    def applicant_postcode(_options)
      applicant.address.postcode
    end

    def lead_proceeding_cost_limitation_substantive(_options)
      lead_proceeding_type.default_cost_limitation_substantive
    end

    def lead_proceeding_category_of_law(_options)
      lead_proceeding_type.ccms_category_law
    end

    def lead_proceeding_category_of_law_is_family?(_options)
      lead_proceeding_type.ccms_category_law == 'Family'
    end

    def lead_proceeding_category_of_law_meaning(_options)
      lead_proceeding_type.meaning
    end

    def lead_proceeding_category_of_law_code(_options)
      lead_proceeding_type.ccms_category_law_code
    end

    def application_substantive?(_options)
      !legal_aid_application.used_delegated_functions?
    end

    def proceeding_proceeding_application_type(_options)
      legal_aid_application.used_delegated_functions? ? 'Both' : 'Substantive'
    end

    def no_warning_letter_sent?(_options)
      !legal_aid_application.opponent.warning_letter_sent
    end

    def applicant_owns_main_home?(_options)
      !legal_aid_application.own_home_no?
    end

    def applicant_shares_ownership_main_home?(_options)
      (not_zero? legal_aid_application.percentage_home) && legal_aid_application.percentage_home < 100
    end

    def applicant_owns_percentage_main_home(_options)
      legal_aid_application.percentage_home
    end

    def third_party_owns_percentage_main_home(_options)
      100 - legal_aid_application.percentage_home
    end

    def applicant_property_value(_options)
      legal_aid_application.property_value
    end

    def outstanding_mortgage?(_options)
      !legal_aid_application&.own_home_no? && legal_aid_application&.own_home_mortgage? && legal_aid_application&.outstanding_mortgage_amount
    end

    def outstanding_mortgage_amount(_options)
      legal_aid_application.outstanding_mortgage_amount
    end

    def applicant_has_vehicle?(_options)
      vehicle.present? && not_zero?(vehicle.estimated_value)
    end

    def ccms_equivalent_prospects_of_success(_options)
      return unless ccms_equivalent_prospects_of_success_valid?

      PROSPECTS_OF_SUCCESS[chances_of_success.success_prospect.to_sym][:text]
    end

    def ccms_code_prospects_of_success(_options)
      return unless ccms_equivalent_prospects_of_success_valid?

      PROSPECTS_OF_SUCCESS[chances_of_success.success_prospect.to_sym][:code]
    end

    def ccms_equivalent_prospects_of_success_valid?
      PROSPECTS_OF_SUCCESS[chances_of_success.success_prospect.to_sym].present?
    end

    def client_eligibility(_options)
      case cfe_result.assessment_result
      when 'eligible', 'contribution_required'
        'In Scope'
      when 'not_eligible'
        'Out Of Scope'
      else
        raise "Unexpected assessment result: #{cfe_result.assessment_result}"
      end
    end

    def means_assessment_capital_contribution(_options)
      cfe_result.capital_contribution_required? ? cfe_result.capital_contribution : 0.0
    end

    def means_assessment_income_contribution(_options)
      cfe_result.income_contribution_required? ? cfe_result.income_contribution : 0.0
    end

    def benefit_check_passed?(_options)
      legal_aid_application.benefit_check_result.result == 'Yes'
    end

    def proceeding_cost_limitation(options)
      application_proceeding_type = options[:appl_proceeding_type]
      return 'MULTIPLE' if application_proceeding_type.assigned_scope_limitations.size > 1

      application_proceeding_type.assigned_scope_limitations.first.code
    end

    private

    def applicant
      @applicant ||= legal_aid_application.applicant
    end

    def lead_proceeding_type
      @lead_proceeding_type ||= legal_aid_application.lead_proceeding_type
    end

    def standardly_named_method?(method)
      STANDARD_METHOD_NAMES.match?(method)
    end

    def savings
      @savings ||= legal_aid_application.savings_amount
    end

    def other_assets
      @other_assets ||= legal_aid_application.other_assets_declaration
    end

    def cfe_result
      @cfe_result ||= legal_aid_application.cfe_result
    end

    def proceeding_limitation_desc(options)
      used_delegated_functions? ? 'MULTIPLE' : substantive_scope_limitation(options).description
    end

    def substantive_scope_limitation(options)
      options[:appl_proceeding_type].substantive_scope_limitation
    end

    def proceeding_description(_options)
      lead_proceeding_type.description
    end

    def proceeding_limitation_meaning(options)
      used_delegated_functions? ? 'MULTIPLE' : substantive_scope_limitation(options).meaning
    end

    def call_standard_method(method, options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      case method
      when APPLICATION_REGEX
        legal_aid_application.__send__(Regexp.last_match(1))
      when APPLICANT_REGEX
        applicant.__send__(Regexp.last_match(1))
      when APPLICATION_PROCEEDING_TYPE_REGEX
        options[:appl_proceeding_type].__send__(Regexp.last_match(1))
      when BANK_REGEX
        options[:bank_acct].__send__(Regexp.last_match(1))
      when CHANCES_OF_SUCCESS
        options[:chances_of_success].__send__(Regexp.last_match(1))
      when VEHICLE_REGEX
        options[:vehicle].__send__(Regexp.last_match(1))
      when WAGE_SLIP_REGEX
        options[:wage_slip].__send__(Regexp.last_match(1))
      when PROCEEDING_REGEX
        options[:proceeding].__send__(Regexp.last_match(1))
      when INCOME_TYPE_REGEX
        legal_aid_application.transaction_types.for_income_type?(Regexp.last_match(1).chomp('?'))
      when OPPONENT
        options[:opponent].__send__(Regexp.last_match(1))
      when OUTGOING
        legal_aid_application.transaction_types.for_outgoing_type?(Regexp.last_match(1).chomp('?'))
      when SAVINGS_AMOUNT
        legal_aid_application.savings_amount.__send__(Regexp.last_match(1))
      when OTHER_ASSETS_DECLARATION
        legal_aid_application.other_assets_declaration.__send__(Regexp.last_match(1))
      when LEAD_PROCEEDING_TYPE
        legal_aid_application.lead_proceeding_type.__send__(Regexp.last_match(1))
      end
    end

    def not_zero?(value)
      value.present? && value.positive?
    end

    def bypass_manual_review_in_ccms?(_options)
      !manual_case_review_required?
    end

    def manual_case_review_required?
      ManualReviewDeterminer.new(legal_aid_application).manual_review_required?
    end

    def chances_of_success
      legal_aid_application.application_proceeding_types.first.chances_of_success
    end
  end
end
