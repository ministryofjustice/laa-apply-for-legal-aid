module CCMS
  # This class is used to generate the Attribute key-value XML block within the instances of the
  # various entities on the CCMS add request payload.  Each possible key value pair has an
  # entry in the /config/ccms/ccms_keys.yml file.
  #
  # Each key in the ccms_keys.yml file has the following attributes:
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
  #  'vehicle_registration_number'  will call the registraion_number method on options[:vehicle] in order to get the
  # value to insert.
  class AttributeValueGenerator
    STANDARD_METHOD_NAMES = /^(bank_account|vehicle|wage_slip|proceeding)_(\S+)$/.freeze
    BANK_REGEX = /^bank_account_(\S+)$/.freeze
    VEHICLE_REGEX = /^vehicle_(\S+)$/.freeze
    WAGE_SLIP_REGEX = /^wage_slip_(\S+)$/.freeze
    PROCEEDING_REGEX = /^proceeding_(\S+)$/.freeze

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
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
      1000.0
    end

    def application_ccms_reference_number(_options)
      @legal_aid_application.ccms_reference_number
    end

    def bank_name(options)
      options[:bank_acct].bank_provider.name
    end

    def bank_account_holders(_options)
      'Client Sole'
    end

    def means_assessment_capital_contribution(_options)
      @legal_aid_application.means_assessment_result.capital_contribution
    end

    def lead_proceeding_category(_options)
      @legal_aid_application.lead_proceeding.ccms_category_law_code
    end

    def main_dwelling_third_party_name(_options)
      @legal_aid_application.main_dwelling_third_party_name
    end

    def main_dwelling_third_party_relationship(_options)
      @legal_aid_application.main_dwelling_third_party_relationship
    end

    def main_dwelling_third_party_percentage(_options)
      @legal_aid_application.main_dwelling_third_party_percentage
    end

    private

    def standardly_named_method?(method)
      STANDARD_METHOD_NAMES.match?(method)
    end

    def call_standard_method(method, options)
      case method
      when BANK_REGEX
        options[:bank_acct].send(Regexp.last_match(1))
      when VEHICLE_REGEX
        options[:vehicle].send(Regexp.last_match(1))
      when WAGE_SLIP_REGEX
        options[:wage_slip].send(Regexp.last_match(1))
      when PROCEEDING_REGEX
        options[:proceeding].send(Regexp.last_match(1))
      end
    end
  end
end
