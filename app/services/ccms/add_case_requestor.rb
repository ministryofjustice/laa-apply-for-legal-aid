module CCMS
  class AddCaseRequestor # rubocop:disable Metrics/ClassLength
    NAMESPACES = {
      'xmlns:ns6' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
      'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Finance/Payables/1.0/BillingBIO',
      'xmlns:ns7' => 'uri',
      'xmlns:ns0' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO',
      'xmlns:ns1' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
      'xmlns:ns4' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns3' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
    }.freeze

    WSDL_LOCATION = "#{File.dirname(__FILE__)}/wsdls/CaseServicesWsdl.xml".freeze

    CONFIG_METHOD_REGEX = /^#(\S+)/.freeze

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      @transaction_time_stamp = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%3N')
      @ccms_attribute_keys = YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml'))
      @attribute_value_generator = AttributeValueGenerator.new(@legal_aid_application)
    end

    def request
      @request ||= build_request
    end

    def formatted_xml
      result = ''
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      formatter.width = 500
      formatter.write(REXML::Document.new(request.to_xml), result)
      result
    end

    private

    def build_request
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.__send__('ns7:CaseAddRQ', NAMESPACES) do
          xml.__send__('ns6:HeaderRQ') { header_request(xml) }
          xml.__send__('ns1:Case') { case_request(xml) }
        end
      end
    end

    def header_request(xml)
      xml.__send__('ns6:TransactionRequestID', transaction_request_id)
      xml.__send__('ns6:Language', 'ENG')
      xml.__send__('ns6:Source', 'PUI')
      xml.__send__('ns6:Target', 'Oracle EBusiness')
      xml.__send__('ns6:UserLoginID', 'DAVIDGRAYLLPTWO')
      xml.__send__('ns6:UserRole', 'EXTERNAL')
      xml.__send__('ns6:TimeStamp', @transaction_time_stamp)
    end

    def case_request(xml)
      xml.__send__('ns2:CaseReferenceNumber', @legal_aid_application.ccms_reference_number)
      xml.__send__('ns2:CaseDetails') do
        xml.__send__('ns2:ApplicationDetails') { generate_application_details(xml) }
        xml.__send__('ns2:RecordHistory') { generate_record_history(xml) }
        xml.__send__('ns2:CaseDocs')
      end
    end

    def transaction_request_id
      @transaction_request_id ||= Time.now.strftime('%Y%m%d%H%M%S%6N')
    end

    def generate_application_details(xml) # rubocop:disable Metrics/AbcSize
      xml.__send__('ns2:Client') { generate_client(xml) }
      xml.__send__('ns2:PreferredAddress', applicant.preferred_address)
      xml.__send__('ns2:ProviderDetails') { generate_provider_details(xml) }
      xml.__send__('ns2:CategoryOfLaw') { generate_category_of_law(xml) }
      xml.__send__('ns2:OtherParties') { generate_other_parties(xml) }
      xml.__send__('ns2:Proceedings') { generate_proceedings(xml) }
      xml.__send__('ns2:MeansAssesments') { generate_means_assessment(xml) }
      xml.__send__('ns2:MeritsAssesments') { generate_merits_assessment(xml) }
      xml.__send__('ns2:DevolvedPowersDate', '2019-04-01')
      xml.__send__('ns2:ApplicationAmendmentType', 'SUBDP')
      xml.__send__('ns2:LARDetails') { generate_lar_details(xml) }
    end

    # hard coded to match expected payload for now - until we decide what to do about other parties
    def generate_other_parties(xml) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      xml.__send__('ns2:OtherParty') do
        xml.__send__('ns2:OtherPartyID', 'OPPONENT_11594796')
        xml.__send__('ns2:SharedInd', false)
        xml.__send__('ns2:OtherPartyDetail') do
          xml.__send__('ns2:Person') do
            xml.__send__('ns2:Name') do
              xml.__send__('ns0:Title', 'MRS.')
              xml.__send__('ns0:Surname', 'Fabby')
              xml.__send__('ns0:FirstName', 'Fabby')
            end
            xml.__send__('ns2:DateOfBirth', '1980-01-01')
            xml.__send__('ns2:Address')
            xml.__send__('ns2:RelationToClient', 'EX_SPOUSE')
            xml.__send__('ns2:RelationToCase', 'OPP')
            xml.__send__('ns2:ContactDetails')
            xml.__send__('ns2:AssessedIncome', 0)
            xml.__send__('ns2:AssessedAsstes', 0)
          end
        end
      end

      xml.__send__('ns2:OtherParty') do
        xml.__send__('ns2:OtherPartyID', 'OPPONENT_11594798')
        xml.__send__('ns2:SharedInd', false)
        xml.__send__('ns2:OtherPartyDetail') do
          xml.__send__('ns2:Person') do
            xml.__send__('ns2:Name') do
              xml.__send__('ns0:Title', 'MASTER')
              xml.__send__('ns0:Surname', 'Fabby')
              xml.__send__('ns0:FirstName', 'BoBo')
            end
            xml.__send__('ns2:DateOfBirth', '2015-01-01')
            xml.__send__('ns2:Address')
            xml.__send__('ns2:RelationToClient', 'CHILD')
            xml.__send__('ns2:RelationToCase', 'CHILD')
            xml.__send__('ns2:ContactDetails')
            xml.__send__('ns2:AssessedIncome', 0)
            xml.__send__('ns2:AssessedAsstes', 0)
          end
        end
      end
    end

    def generate_record_history(xml)
      xml.__send__('ns0:DateCreated', Time.now.strftime('%Y-%m-%dT%H:%M:%S.%3N'))
      xml.__send__('ns0:LastUpdatedBy') do
        xml.__send__('ns0:UserLoginID', 'DAVIDGRAYLLPTWO')
        xml.__send__('ns0:UserName', 'DAVIDGRAYLLPTWO')
        xml.__send__('ns0:UserType', 'EXTERNAL')
      end
      xml.__send__('ns0:DateLastUpdated', Time.now.strftime('%Y-%m-%dT%H:%M:%S.%3N'))
    end

    def generate_lar_details(xml)
      xml.__send__('ns2:LARScopeFlag', true)
    end

    def generate_client(xml)
      xml.__send__('ns2:ClientReferenceNumber', applicant.ccms_reference_number)
      xml.__send__('ns2:FirstName', applicant.first_name)
      xml.__send__('ns2:Surname', applicant.last_name)
    end

    def generate_provider_details(xml)
      xml.__send__('ns2:ProviderCaseReferenceNumber', @legal_aid_application.provider_case_reference_number)
      xml.__send__('ns2:ProviderFirmID', provider.firm_id)
      xml.__send__('ns2:ProviderOfficeID', provider.office_id)
      xml.__send__('ns2:ContactUserID') do
        xml.__send__('ns0:UserLoginID', provider.user_login_id)
      end
      xml.__send__('ns2:SupervisorContactID', provider.supervisor_user_id)
      xml.__send__('ns2:FeeEarnerContactID', provider.fee_earner_contact_id)
    end

    def generate_category_of_law(xml)
      xml.__send__('ns2:CategoryOfLawCode', lead_proceeding.ccms_category_law_code)
      xml.__send__('ns2:CategoryOfLawDescription', lead_proceeding.ccms_category_law)
      xml.__send__('ns2:RequestedAmount', as_currency(@legal_aid_application.requested_amount))
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
          xml.__send__('ns2:LevelOfService', 3)
          xml.__send__('ns2:Stage', 8)
          xml.__send__('ns2:ClientInvolvementType', 'A')
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
        xml.__send__('ns0:Attribute', 'CLIENT_PROV_LA')
        xml.__send__('ns0:AttributeValue', true)
      end
    end

    def generate_means_assessment_details(xml) # rubocop:disable Metrics/AbcSize
      xml.__send__('ns0:AssessmentScreens') do
        xml.__send__('ns0:ScreenName', 'SUMMARY')
        xml.__send__('ns0:Entity') { generate_valuable_possessions_entity(xml, 1) }
        xml.__send__('ns0:Entity') { generate_bank_accounts_entity(xml, 2) }
        xml.__send__('ns0:Entity') { generate_change_in_circumstance_entity(xml, 3) }
        xml.__send__('ns0:Entity') { generate_vehicles_entity(xml, 4) }
        xml.__send__('ns0:Entity') { generate_wage_slip_entity(xml, 5) }
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
        xml.__send__('ns0:InstanceLabel', 'the valuable possession1')
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
        xml.__send__('ns0:InstanceLabel', 'the change in circumstance1')
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :change_in_circumstances) }
      end
    end

    def generate_vehicles_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CARS_AND_MOTOR_VEHICLES')
      vehicles.each { |vehicle| generate_vehicle_instance(xml, vehicle) }
    end

    def generate_vehicle_instance(xml, vehicle)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', vehicle.instance_label)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :vehicles, vehicle: vehicle) }
      end
    end

    def generate_wage_slip_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CLI_NON_HM_WAGE_SLIP')
      wage_slips.each { |slip| generate_wage_slip_instance(xml, slip) }
    end

    def generate_wage_slip_instance(xml, slip)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', slip.description)
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
      xml.__send__('ns0:Instances')
    end

    def generate_global_means_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'global')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', @legal_aid_application.ccms_reference_number)
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :global_means) }
      end
    end

    def generate_employment_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'EMPLOYMENT_CLIENT')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', '300000333864:EMPLOYMENT_CLIENT_001')
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :employment) }
      end
    end

    def generate_third_party_dwelling_owner_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'MAINTHIRD')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the third party who part owns the main dwelling1')
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
        xml.__send__('ns0:InstanceLabel', @legal_aid_application.ccms_reference_number)
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
        xml.__send__('ns0:InstanceLabel', 'the family statement of case1')
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :family_statement) }
      end
    end

    def generate_opponent_other_parties(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
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
        raise "Unknown response type: #{config[:response_type]}"
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

    def vehicles
      @vehicles ||= @legal_aid_application.vehicles
    end

    def wage_slips
      @wage_slips ||= @legal_aid_application.wage_slips
    end
  end
end
