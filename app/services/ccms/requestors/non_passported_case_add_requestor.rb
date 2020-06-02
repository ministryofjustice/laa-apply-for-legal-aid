module CCMS
  module Requestors
    class NonPassportedCaseAddRequestor < CaseAddRequestor
      wsdl_from Rails.configuration.x.ccms_soa.caseServicesWsdl

      uses_namespaces(
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns6' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Finance/Payables/1.0/BillingBIO',
        'xmlns:ns0' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO',
        'xmlns:ns4' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
        'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:ns3' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
      )

      private

      def means_entity_config_file
        MEANS_ENTITY_CONFIG_DIR.join('non_passported.yml')
      end

      def national_savings_present?
        not_nil_or_zero? @legal_aid_application.savings_amount.national_savings
      end

      def capital_share_present?
        not_nil_or_zero? @legal_aid_application.savings_amount.plc_shares
      end

      def not_nil_or_zero?(value)
        value.present? && value.nonzero?
      end

      def attribute_configuration
        AttributeConfiguration.new(application_type: :non_passported).config
      end

      def applicant_recieves_financial_support?
        @legal_aid_application.bank_transactions.for_type('friends_or_family').any?
      end

      def applicant_has_access_to_other_person_account?
        not_nil_or_zero? @legal_aid_application.savings_amount.other_person_account
      end

      def applicant_has_premium_bonds?
        not_nil_or_zero? @legal_aid_application.savings_amount.national_savings
      end

      def applicant_has_money_due?
        not_nil_or_zero? @legal_aid_application.other_assets_declaration.money_owed_value
      end

      def applicant_has_capital_bonds?
        not_nil_or_zero? @legal_aid_application.savings_amount.peps_unit_trusts_capital_bonds_gov_stocks
      end

      def add_property_instance_label
        "#{submission_case_ccms_reference}:ADDPROPERTY_001"
      end

      def applicant_has_second_home?
        not_nil_or_zero? @legal_aid_application.other_assets_declaration.second_home_value
      end

      def applicant_has_shares?
        not_nil_or_zero? @legal_aid_application.savings_amount.plc_shares
      end

      def applicant_has_life_assurance?
        not_nil_or_zero? @legal_aid_application.savings_amount.life_assurance_endowment_policy
      end

      def applicant_owns_share_of_property?
        @legal_aid_application.property_value.present? &&
          @legal_aid_application.percentage_home.present? &&
          @legal_aid_application.percentage_home < 100.0
      end

      def applicant_has_inherited_assets?
        not_nil_or_zero? @legal_aid_application.other_assets_declaration.inherited_assets_value
      end

      def applicant_is_beneficiary_of_trust?
        not_nil_or_zero? @legal_aid_application.other_assets_declaration.trust_value
      end
    end
  end
end
