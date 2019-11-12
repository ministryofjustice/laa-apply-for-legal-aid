module CCMS
  class CaseAddRequestor < BaseRequestor # rubocop:disable Metrics/ClassLength
    CONFIG_METHOD_REGEX = /^#(\S+)/.freeze

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

    def initialize(submission, options)
      @options = options
      @submission = submission
      @legal_aid_application = submission.legal_aid_application
      @transaction_time_stamp = Time.now.to_s(:ccms_date_time)
      @ccms_attribute_keys = YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml'))
      @attribute_value_generator = AttributeValueGenerator.new(@submission)
    end

    def call
      save_request(@options[:case_type]) unless Rails.env.production?
      soap_client.call(:create_case_application, xml: request_xml) unless @options[:no_call]
    end

    private

    # :nocov:
    def save_request(case_type)
      File.open(Rails.root.join("ccms_integration/generated/add_#{case_type}_case_request.xml"), 'w') do |fp|
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
      xml.__send__('ns6:UserLoginID', provider.username)
      xml.__send__('ns6:UserRole', 'EXTERNAL') # TODO: CCMS placeholder
    end

    def case_request(xml)
      xml.__send__('ns2:CaseReferenceNumber', @submission.case_ccms_reference)
      xml.__send__('ns2:CaseDetails') do
        xml.__send__('ns2:ApplicationDetails') { generate_application_details(xml) }
        xml.__send__('ns2:RecordHistory') { generate_record_history(xml) }
        xml.__send__('ns2:CaseDocs') { generate_case_docs(xml) }
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
      xml.__send__('ns2:DevolvedPowersDate', '2019-04-01') # TODO: CCMS placeholder
      xml.__send__('ns2:ApplicationAmendmentType', @legal_aid_application.used_delegated_functions? ? 'SUBDP' : 'SUB')
      xml.__send__('ns2:LARDetails') { generate_lar_details(xml) }
    end

    def generate_case_docs(xml)
      @submission.submission_document.each do |document|
        xml.__send__('ns2:CaseDoc') do
          xml.__send__('ns2:CCMSDocumentID', document.ccms_document_id)
          xml.__send__('ns2:DocumentSubject', document.document_type)
        end
      end
    end

    def generate_other_parties(xml)
      generate_other_party(xml)
    end

    def generate_other_party(xml) # rubocop:disable Metrics/MethodLength
      xml.__send__('ns2:OtherParty') do
        xml.__send__('ns2:OtherPartyID', 'OPPONENT_7713451')
        xml.__send__('ns2:SharedInd', false)
        xml.__send__('ns2:OtherPartyDetail') do
          xml.__send__('ns2:Organization') do
            xml.__send__('ns2:OrganizationName', 'APPLY service application')
            xml.__send__('ns2:OrganizationType', 'GOVT')
            xml.__send__('ns2:RelationToClient', 'NONE')
            xml.__send__('ns2:RelationToCase', 'OPP')
            xml.__send__('ns2:Address')
            xml.__send__('ns2:ContactDetails')
          end
        end
      end
    end

    def generate_record_history(xml)
      xml.__send__('ns0:DateCreated', Time.now.to_s(:ccms_date_time))
      xml.__send__('ns0:LastUpdatedBy') do
        xml.__send__('ns0:UserLoginID', provider.username)
        xml.__send__('ns0:UserName', provider.username)
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
      xml.__send__('ns2:ProviderFirmID', provider.firm.ccms_id)
      xml.__send__('ns2:ProviderOfficeID', @legal_aid_application.office.ccms_id)
      xml.__send__('ns2:ContactUserID') do
        xml.__send__('ns0:UserLoginID', provider.user_login_id)
      end
    end

    def generate_category_of_law(xml)
      xml.__send__('ns2:CategoryOfLawCode', @legal_aid_application.lead_proceeding_type.ccms_category_law_code)
      xml.__send__('ns2:CategoryOfLawDescription', @legal_aid_application.lead_proceeding_type.ccms_category_law)
      xml.__send__('ns2:RequestedAmount', @legal_aid_application.default_cost_limitation)
    end

    def generate_proceedings(xml)
      @legal_aid_application.application_proceeding_types.each { |apt| generate_proceeding(xml, apt) }
    end

    def generate_proceeding(xml, application_proceeding_type)
      xml.__send__('ns2:Proceeding') do
        xml.__send__('ns2:ProceedingCaseID', application_proceeding_type.proceeding_case_p_num)
        xml.__send__('ns2:Status', 'Draft')
        xml.__send__('ns2:LeadProceedingIndicator', true)
        xml.__send__('ns2:ProceedingDetails') { generate_proceeding_type(xml, ProceedingType.find(application_proceeding_type.proceeding_type_id)) }
      end
    end

    def generate_proceeding_type(xml, proceeding_type)
      xml.__send__('ns2:ProceedingType', proceeding_type.ccms_code)
      xml.__send__('ns2:ProceedingDescription', proceeding_type.description)
      xml.__send__('ns2:MatterType', proceeding_type.ccms_matter_code)
      xml.__send__('ns2:LevelOfService', proceeding_type.default_level_of_service.service_level_number)
      xml.__send__('ns2:Stage', 8) # TODO: CCMS placeholder
      xml.__send__('ns2:ClientInvolvementType', 'A') # TODO: CCMS placeholder
      xml.__send__('ns2:ScopeLimitations') { generate_scope_limitations(xml) }
    end

    def generate_scope_limitations(xml)
      @legal_aid_application.scope_limitations.each { |limitation| generate_scope_limitation(xml, limitation) }
    end

    def generate_scope_limitation(xml, limitation)
      xml.__send__('ns2:ScopeLimitation') do
        xml.__send__('ns2:ScopeLimitation', limitation.code)
        xml.__send__('ns2:ScopeLimitationWording', limitation.description)
        xml.__send__('ns2:DelegatedFunctionsApply', limitation.delegated_functions)
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
        sequence_no = 0
        xml.__send__('ns0:Entity') { generate_valuable_possessions_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_bank_accounts_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_vehicles_entity(xml, sequence_no += 1) } if @legal_aid_application.vehicle.present?
        xml.__send__('ns0:Entity') { generate_wage_slips_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_means_proceeding_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_other_parties_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_global_means_entity(xml, sequence_no += 1) }
        xml.__send__('ns0:Entity') { generate_employment_entity(xml, sequence_no += 1) }
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

    def generate_vehicles_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'CARS_AND_MOTOR_VEHICLES')
      generate_vehicle_instance(xml, vehicle) if vehicle
    end

    def generate_vehicle_instance(xml, vehicle)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'the cars & motor vehicles')
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
      application_proceeding_types.reverse_each do |application_proceeding_type|
        generate_means_proceeding_instance(xml, application_proceeding_type)
      end
    end

    def generate_means_proceeding_instance(xml, application_proceeding_type)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', @submission.case_ccms_reference)
        xml.__send__('ns0:Attributes') do
          generate_attributes_for(xml,
                                  :proceeding,
                                  appl_proceeding_type: application_proceeding_type,
                                  proceeding: application_proceeding_type.proceeding_type)
        end
      end
    end

    def generate_other_parties_entity(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'OPPONENT_7713451')
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :other_party) }
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
      application_proceeding_types.reverse_each { |apt| generate_merits_proceeding_instance(xml, apt) }
    end

    def generate_merits_proceeding_instance(xml, application_proceeding_type)
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', @submission.case_ccms_reference)
        xml.__send__('ns0:Attributes') do
          generate_attributes_for(xml,
                                  :proceeding_merits,
                                  appl_proceeding_type: application_proceeding_type,
                                  proceeding: application_proceeding_type.proceeding_type,
                                  respondent: @legal_aid_application.respondent)
        end
      end
    end

    def generate_opponent_other_parties(xml, sequence_no)
      xml.__send__('ns0:SequenceNumber', sequence_no)
      xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
      xml.__send__('ns0:Instances') do
        xml.__send__('ns0:InstanceLabel', 'OPPONENT_7713451')
        xml.__send__('ns0:Attributes') { generate_attributes_for(xml, :opponent) }
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
        raise CcmsError, "Submission #{@submission.id} - Unknown response type: #{config[:response_type]}"
      end
    end

    def as_currency(raw_value)
      format('%<amount>.2f', amount: raw_value)
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

    def application_proceeding_types
      @application_proceeding_types ||= @legal_aid_application.application_proceeding_types
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
