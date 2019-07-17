module CCMS
  class CaseAddRequestor < BaseRequestor # rubocop:disable Metrics/ClassLength
    CONFIG_METHOD_REGEX = /^#(\S+)/.freeze

    wsdl_from 'CaseServicesWsdl.xml'.freeze

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

    def initialize(submission, options)
      @options = options
      @submission = submission
      @legal_aid_application = submission.legal_aid_application
      @transaction_time_stamp = Time.now.to_s(:ccms_date_time)
      @ccms_attribute_keys = YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml'))
      @attribute_value_generator = AttributeValueGenerator.new(@legal_aid_application)
    end

    def call
      save_request unless Rails.env.production?
      soap_client.call(:create_case_application, xml: request_xml) unless @options[:no_call]
    end

    private

    # :nocov:
    def save_request
      File.open(Rails.root.join('ccms_integration/generated/add_case_request.xml'), 'w') do |fp|
        fp.puts request_xml
      end
    end
    # :nocov:

    def request_xml
      @request_xml ||= soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns4:CaseAddRQ') do
        xml.__send__('ns6:HeaderRQ') { header_request(xml) }
        xml.__send__('ns4:Case') { case_request(xml) }
      end
    end

    def header_request(xml)
      xml.__send__('ns6:TransactionRequestID', transaction_request_id)
      xml.__send__('ns6:Language', 'ENG') # TODO: CCMS placeholder
      xml.__send__('ns6:UserLoginID', 'NEETADESOR') # TODO: CCMS placeholder
      xml.__send__('ns6:UserRole', 'EXTERNAL') # TODO: CCMS placeholder
    end

    def case_request(xml)
      xml.__send__('ns2:CaseReferenceNumber', @submission.case_ccms_reference)
      xml.__send__('ns2:CaseDetails') do
        xml.__send__('ns2:ApplicationDetails') { generate_application_details(xml) }
        xml.__send__('ns2:RecordHistory') { generate_record_history(xml) }
        xml.__send__('ns2:CaseDocs')
      end
    end

    def generate_application_details(xml) # rubocop:disable Metrics/AbcSize
      xml.__send__('ns2:Client') { generate_client(xml) }
      xml.__send__('ns2:PreferredAddress', 'CLIENT') # TODO: CCMS placeholder
      xml.__send__('ns2:ProviderDetails') { generate_provider_details(xml) }
      xml.__send__('ns2:CategoryOfLaw') { generate_category_of_law(xml) }
      xml.__send__('ns2:OtherParties') { generate_other_parties(xml) }
      xml.__send__('ns2:Proceedings') { generate_proceedings(xml) }
      xml.__send__('ns2:MeansAssesments') { generate_means_assessment(xml) }
      xml.__send__('ns2:MeritsAssesments') { generate_merits_assessment(xml) }
      xml.__send__('ns2:DevolvedPowersDate', '2019-04-01')  # TODO: CCMS placeholder
      xml.__send__('ns2:ApplicationAmendmentType', 'SUBDP') # TODO: CCMS placeholder
      xml.__send__('ns2:LARDetails') { generate_lar_details(xml) }
    end

    def generate_other_parties(xml)
      @legal_aid_application.opponent_other_parties.each do |opponent|
        generate_other_party(xml, opponent)
      end
    end

    def generate_other_party(xml, opponent) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      xml.__send__('ns2:OtherParty') do
        xml.__send__('ns2:OtherPartyID', opponent.other_party_id)
        xml.__send__('ns2:SharedInd', opponent.shared_ind)
        xml.__send__('ns2:OtherPartyDetail') do
          xml.__send__('ns2:Person') do
            xml.__send__('ns2:Name') do
              xml.__send__('ns0:Title', opponent.title)
              xml.__send__('ns0:Surname', opponent.surname)
              xml.__send__('ns0:FirstName', opponent.first_name)
            end
            xml.__send__('ns2:DateOfBirth', opponent.date_of_birth.strftime('%Y-%m-%d'))
            xml.__send__('ns2:Address')
            xml.__send__('ns2:RelationToClient', opponent.relationship_to_client)
            xml.__send__('ns2:RelationToCase', opponent.relationship_to_case)
            xml.__send__('ns2:ContactDetails')
            xml.__send__('ns2:AssessedIncome', opponent.assessed_income)
            xml.__send__('ns2:AssessedAsstes', opponent.assessed_assets)
          end
        end
      end
    end

    def generate_record_history(xml)
      xml.__send__('ns0:DateCreated', Time.now.to_s(:ccms_date_time))
      xml.__send__('ns0:LastUpdatedBy') do
        xml.__send__('ns0:UserLoginID', 'NEETADESOR') # TODO: CCMS placeholder
        xml.__send__('ns0:UserName', 'NEETADESOR') # TODO: CCMS placeholder
        xml.__send__('ns0:UserType', 'EXTERNAL') # TODO: CCMS placeholder
      end
      xml.__send__('ns0:DateLastUpdated', Time.now.to_s(:ccms_date_time))
    end

    def generate_lar_details(xml)
      xml.__send__('ns2:LARScopeFlag', true) # TODO: CCMS placeholder
    end

    def generate_client(xml)
      xml.__send__('ns2:ClientReferenceNumber', @submission.applicant_ccms_reference)
      xml.__send__('ns2:FirstName', applicant.first_name)
      xml.__send__('ns2:Surname', applicant.last_name)
    end

    def generate_provider_details(xml)
      xml.__send__('ns2:ProviderCaseReferenceNumber', 'PC4') # TODO: insert @legal_aid_application.provider_case_reference_number when it is available in Apply
      xml.__send__('ns2:ProviderFirmID', provider.firm_id)
      xml.__send__('ns2:ProviderOfficeID', provider.office_id)
      xml.__send__('ns2:ContactUserID') do
        xml.__send__('ns0:UserLoginID', provider.username)
      end
      xml.__send__('ns2:SupervisorContactID', provider.supervisor_contact_id)
      xml.__send__('ns2:FeeEarnerContactID', provider.fee_earner_contact_id)
    end

    def generate_category_of_law(xml)
      xml.__send__('ns2:CategoryOfLawCode', 'MAT') # TODO: replace with lead_proceeding.ccms_category_law_code when it is available in Apply
      xml.__send__('ns2:CategoryOfLawDescription', 'Family') # TODO: insert lead_proceeding.ccms_category_law when it is available in Apply
      xml.__send__('ns2:RequestedAmount', '5000.0') # TODO: replace with as_currency(@legal_aid_application.requested_amount)) when it is available in Apply
    end

    def generate_proceedings(xml)
      @legal_aid_application.proceeding_types.each { |p| generate_proceeding(xml, p) }
    end

    def generate_proceeding(xml, proceeding) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      xml.__send__('ns2:Proceeding') do
        xml.__send__('ns2:ProceedingCaseID', proceeding.case_id)
        xml.__send__('ns2:Status', proceeding.status)
        xml.__send__('ns2:LeadProceedingIndicator', proceeding.lead_proceeding_indicator)
        xml.__send__('ns2:ProceedingDetails') do
          xml.__send__('ns2:ProceedingType', proceeding.ccms_code)
          xml.__send__('ns2:ProceedingDescription', proceeding.description)
          xml.__send__('ns2:MatterType', proceeding.ccms_matter_code)
          xml.__send__('ns2:LevelOfService', 3) # TODO: CCMS placeholder
          xml.__send__('ns2:Stage', 8) # TODO: CCMS placeholder
          xml.__send__('ns2:ClientInvolvementType', 'A') # TODO: CCMS placeholder
          xml.__send__('ns2:ScopeLimitations') { generate_scope_limitations(xml, proceeding) }
        end
      end
    end

    def generate_scope_limitations(xml, proceeding)
      proceeding.scope_limitations.each { |limitation| generate_scope_limitation(xml, limitation) }
    end

    def generate_scope_limitation(xml, limitation)
      xml.__send__('ns2:ScopeLimitation') do
        xml.__send__('ns2:ScopeLimitation', limitation.limitation)
        xml.__send__('ns2:ScopeLimitationWording', limitation.wording)
        xml.__send__('ns2:DelegatedFunctionsApply', limitation.delegated_functions_apply)
      end
    end

    def generate_means_assessment(xml)
      xml.__send__('ns2:AssesmentResults') do
        xml.__send__('ns0:Results') { generate_means_assessment_results(xml) }
        xml.__send__('ns0:AssesmentDetails') { generate_means_assessment_details(xml) }
      end
    end

    def generate_means_assessment_results(xml)
      xml.__send__('ns0:Goal') do
        xml.__send__('ns0:Attribute', 'CLIENT_PROV_LA') # TODO: CCMS placeholder
        xml.__send__('ns0:AttributeValue', true) # TODO: CCMS placeholder
      end
    end

    def generate_means_assessment_details(xml) # rubocop:disable Metrics/AbcSize
      xml.__send__('ns0:AssessmentScreens') do
        xml.__send__('ns0:ScreenName', 'SUMMARY')
        xml.__send__('ns0:Entity') { generate_valuable_possessions_entity(xml, 1) }
        xml.__send__('ns0:Entity') { generate_bank_accounts_entity(xml, 2) }
        xml.__send__('ns0:Entity') { generate_change_in_circumstance_entity(xml, 3) }
        xml.__send__('ns0:Entity') { generate_vehicles_entity(xml, 4) }
        xml.__send__('ns0:Entity') { generate_wage_slips_entity(xml, 5) }
        xml.__send__('ns0:Entity') { generate_means_proceeding_entity(xml, 6) }
        xml.__send__('ns0:Entity') { generate_other_parties_entity(xml, 7) }
        xml.__send__('ns0:Entity') { generate_global_means_entity(xml, 8) }
        xml.__send__('ns0:Entity') { generate_employment_entity(xml, 9) }
        xml.__send__('ns0:Entity') { generate_third_party_dwelling_owner_entity(xml, 10) }
      end
    end

    def generate_valuable_possessions_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'VALUABLE_POSSESSION')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the valuable possession1') # TODO: CCMS placeholder
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :valuable_possessions) }
      end
    end

    def generate_bank_accounts_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'BANKACC')
      bank_accounts.each { |acct| generate_bank_account_instance(xml, acct) }
    end

    def generate_bank_account_instance(xml, bank_account)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', bank_account.display_name)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :bank_acct, bank_acct: bank_account) }
      end
    end

    def generate_change_in_circumstance_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CHANGE_IN_CIRCUMSTANCE')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the change in circumstance1') # TODO: CCMS placeholder
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :change_in_circumstances) }
      end
    end

    def generate_vehicles_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CARS_AND_MOTOR_VEHICLES')
      generate_vehicle_instance(xml, vehicle) if vehicle
    end

    def generate_vehicle_instance(xml, vehicle)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the cars & motor vehicles') # TODO: CCMS placeholder
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :vehicles, vehicle: vehicle) }
      end
    end

    def generate_wage_slips_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CLI_NON_HM_WAGE_SLIP')
      wage_slips.each { |slip| generate_wage_slip_instance(xml, slip) }
    end

    def generate_wage_slip_instance(xml, slip)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', "#{@submission.case_ccms_reference}#{slip.description}")
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :wages, wage_slip: slip) }
      end
    end

    def generate_means_proceeding_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'PROCEEDING')
      proceedings.reverse_each { |proceeding| generate_means_proceeding_instance(xml, proceeding) }
    end

    def generate_means_proceeding_instance(xml, proceeding)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', proceeding.case_id)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :proceeding, proceeding: proceeding) }
      end
    end

    def generate_other_parties_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
      @legal_aid_application.opponents.each do |opponent|
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', opponent.other_party_id)
          xml.__send__('ns0:Attributes') do
            generate_attributes_for(xml, :other_party, other_party: opponent)
          end
        end
      end
    end

    def generate_global_means_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'global')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', @submission.case_ccms_reference)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :global_means) }
      end
    end

    def generate_employment_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'EMPLOYMENT_CLIENT')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', "#{@submission.case_ccms_reference}:EMPLOYMENT_CLIENT_001")
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :employment) }
      end
    end

    def generate_third_party_dwelling_owner_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'MAINTHIRD')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the third party who part owns the main dwelling1') # TODO: CCMS placeholder
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :main_dwelling) }
      end
    end

    def generate_merits_assessment(xml)
      xml.__send__('ns2:AssesmentResults') do
        xml.__send__('ns0:Results') { generate_merits_assessment_results(xml) }
        xml.__send__('ns0:AssesmentDetails') { generate_merits_assessment_details(xml) }
      end
    end

    def generate_merits_assessment_results(xml)
      xml.__send__('ns0:Goal') do
        xml.__send__('ns0:Attribute', 'ASSESS_COMPLETE')
        xml.__send__('ns0:AttributeValue', true)
      end
    end

    def generate_merits_assessment_details(xml)
      xml.__send__('ns0:AssessmentScreens') do
        xml.__send__('ns0:ScreenName', 'SUMMARY')
        xml.__send__('ns0:Entity') { generate_global_merits_entity(xml, 1) }
        xml.__send__('ns0:Entity') { generate_merits_proceeding_entity(xml, 2) }
        xml.__send__('ns0:Entity') { generate_family_statement(xml, 3) }
        xml.__send__('ns0:Entity') { generate_opponent_other_parties(xml, 4) }
      end
    end

    def generate_global_merits_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'global')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', @submission.case_ccms_reference)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :global_merits) }
      end
    end

    def generate_merits_proceeding_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'PROCEEDING')
      @legal_aid_application.proceeding_types.reverse_each { |p| generate_merits_proceeding_instance(xml, p) }
    end

    def generate_merits_proceeding_instance(xml, proceeding)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', proceeding.case_id)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :proceeding_merits, proceeding: proceeding) }
      end
    end

    def generate_family_statement(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'FAMILY_STATEMENT')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the family statement of case1') # TODO: CCMS placeholder
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :family_statement) }
      end
    end

    def generate_opponent_other_parties(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
      @legal_aid_application.opponent_other_parties.reverse_each do |oop|
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', oop.other_party_id)
          xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :opponent, opponent: oop) }
        end
      end
    end

    def generate_attributes_for(xml, entity_name, options = {})
      @ccms_attribute_keys[entity_name.to_s].each do |attribute_name, config|
        next unless generate_attribute_block?(config, options)

        response_value = extract_response_value(config, options)
        xml.__send__('ns0:Attribute') do
          xml.__send__('ns0:Attribute', attribute_name)
          xml.__send__('ns0:ResponseType', config[:response_type])
          xml.__send__('ns0:ResponseValue', response_value)
          xml.__send__('ns0:UserDefinedInd', config[:user_defined])
        end
      end
    end

    def generate_attribute_block?(config, options)
      config.key?(:generate_block?) ? evaluate_generate_block_method(config, options) : true
    end

    def evaluate_generate_block_method(config, options)
      return config[:generate_block?] if boolean?(config[:generate_block?])

      method_name = config[:generate_block?].sub(/^#/, '')
      @attribute_value_generator.__send__(method_name, options)
    end

    def extract_response_value(config, options)
      raw_value = extract_raw_value(config, options)
      case config[:response_type]
      when 'text', 'number', 'boolean'
        raw_value
      when 'currency'
        as_currency(raw_value)
      when 'date'
        raw_value.is_a?(Date) ? raw_value.strftime('%d-%m-%Y') : raw_value
      else
        raise CcmsError, "Unknown response type: #{config[:response_type]}"
      end
    end

    def as_currency(raw_value)
      format('%.2f', raw_value)
    end

    def extract_raw_value(config, options)
      if config[:value] == true || config[:value] == false
        config[:value]
      else
        method_name?(config[:value]) ? get_attr_value(config[:value], options) : config[:value]
      end
    end

    def method_name?(str)
      return false unless str.is_a?(String)

      CONFIG_METHOD_REGEX.match?(str)
    end

    def method_name(str)
      str.sub(/^#/, '')
    end

    def get_attr_value(str, options)
      @attribute_value_generator.__send__(method_name(str), options)
    end

    def applicant
      @applicant ||= @legal_aid_application.applicant
    end

    def provider
      @provider ||= @legal_aid_application.provider
    end

    def lead_proceeding
      @lead_proceeding ||= @legal_aid_application.lead_proceeding
    end

    def proceedings
      @proceedings ||= @legal_aid_application.proceeding_types
    end

    def bank_accounts
      @bank_accounts ||= applicant.bank_accounts
    end

    def vehicle
      @vehicle ||= @legal_aid_application.vehicle
    end

    def wage_slips
      @wage_slips ||= @legal_aid_application.wage_slips
    end

    def boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end
end
