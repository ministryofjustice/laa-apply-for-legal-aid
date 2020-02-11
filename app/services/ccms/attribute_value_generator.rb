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
    STANDARD_METHOD_NAMES = /^(application|applicant|bank_account|vehicle|wage_slip|appl_proceeding_type|proceeding|other_party|opponent|respondent)_(\S+)$/.freeze
    APPLICATION_REGEX = /^application_(\S+)$/.freeze
    APPLICANT_REGEX = /^applicant_(\S+)$/.freeze
    APPLICATION_PROCEEDING_TYPE_REGEX = /^appl_proceeding_type_(\S+)$/.freeze
    BANK_REGEX = /^bank_account_(\S+)$/.freeze
    VEHICLE_REGEX = /^vehicle_(\S+)$/.freeze
    WAGE_SLIP_REGEX = /^wage_slip_(\S+)$/.freeze
    PROCEEDING_REGEX = /^proceeding_(\S+)$/.freeze
    OTHER_PARTY = /^other_party_(\S+)$/.freeze
    OPPONENT = /^opponent_(\S+)$/.freeze
    RESPONDENT = /^respondent_(\S+)$/.freeze

    def initialize(submission)
      @submission = submission
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

    def bank_account_holders(_options)
      'Client Sole' # TODO: CCMS placeholder
    end

    def submission_case_ccms_reference(_options)
      @legal_aid_application.case_ccms_reference
    end

    def used_delegated_functions_on(_options)
      @legal_aid_application.used_delegated_functions_on.strftime('%d-%m-%Y')
    end

    def app_amendment_type(_options)
      @legal_aid_application.used_delegated_functions? ? 'SUBDP' : 'SUB'
    end

    def provider_firm_id(_options)
      @legal_aid_application.provider.firm.ccms_id
    end

    def provider_email(_options)
      @legal_aid_application.provider.email
    end

    def applicant_national_insurance_number(_options)
      applicant.national_insurance_number
    end

    def applicant_owed_money?(_options)
      not_zero? other_assets.money_owed_value
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

    def applicant_has_other_capital?(_options)
      not_zero? savings.peps_unit_trusts_capital_bonds_gov_stocks
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
      @legal_aid_application.lead_proceeding_type.default_level_of_service.service_level_number
    end

    def lead_proceeding_type_default_level_of_service_name(_options)
      @legal_aid_application.lead_proceeding_type.default_level_of_service.name
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
      !@legal_aid_application.used_delegated_functions?
    end

    def proceeding_proceeding_application_type(_options)
      @legal_aid_application.used_delegated_functions? ? 'Both' : 'Substantive'
    end

    def no_warning_letter_sent?(_options)
      !@legal_aid_application.respondent.warning_letter_sent
    end

    PROSPECTS_OF_SUCCESS = {
      likely: 'Good',
      marginal: 'Marginal',
      poor: 'Poor',
      borderline: 'Borderline',
      uncertain: 'Uncertain'
    }.freeze

    attr_reader :legal_aid_application
    delegate :merits_assessment, to: :legal_aid_application

    def ccms_equivalent_prospects_of_success(_options)
      PROSPECTS_OF_SUCCESS[merits_assessment.success_prospect.to_sym]
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

    def benefit_check_passed?(_options)
      @legal_aid_application.benefit_check_result.result == 'Yes'
    end

    def proceeding_cost_limitation(_options)
      return 'MULTIPLE' if scope_limitations.size > 1
      scope_limitations.first.code
    end

    private

    def applicant
      @applicant ||= @legal_aid_application.applicant
    end

    def lead_proceeding_type
      @lead_proceeding_type ||= @legal_aid_application.lead_proceeding_type
    end

    def standardly_named_method?(method)
      STANDARD_METHOD_NAMES.match?(method)
    end

    def savings
      @savings ||= @legal_aid_application.savings_amount
    end

    def other_assets
      @other_assets ||= @legal_aid_application.other_assets_declaration
    end

    def cfe_result
      @cfe_result ||= @legal_aid_application.cfe_result
    end

    def scope_limitations
      @scope_limitations ||= @legal_aid_application.scope_limitations
    end

    def call_standard_method(method, options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      case method
      when APPLICATION_REGEX
        @legal_aid_application.__send__(Regexp.last_match(1))
      when APPLICANT_REGEX
        applicant.__send__(Regexp.last_match(1))
      when APPLICATION_PROCEEDING_TYPE_REGEX
        options[:appl_proceeding_type].__send__(Regexp.last_match(1))
      when BANK_REGEX
        options[:bank_acct].__send__(Regexp.last_match(1))
      when VEHICLE_REGEX
        options[:vehicle].__send__(Regexp.last_match(1))
      when WAGE_SLIP_REGEX
        options[:wage_slip].__send__(Regexp.last_match(1))
      when PROCEEDING_REGEX
        options[:proceeding].__send__(Regexp.last_match(1))
      # when OTHER_PARTY  # TODO enable this when a decision is made on how to handle other parties
      #   options[:other_party].__send__(Regexp.last_match(1))
      when OPPONENT
        options[:opponent].__send__(Regexp.last_match(1))
      when RESPONDENT
        options[:respondent].__send__(Regexp.last_match(1))
      end
    end

    def not_zero?(value)
      value.present? && value.positive?
    end
  end
end
