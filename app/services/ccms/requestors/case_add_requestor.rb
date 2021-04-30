require_relative '../payload_generators/entity_attributes_generator'

module CCMS
  module Requestors
    class CaseAddRequestor < BaseRequestor # rubocop:disable Metrics/ClassLength
      include CCMS::PayloadGenerators

      attr_reader :ccms_attribute_keys, :submission

      MEANS_ENTITY_CONFIG_DIR = Rails.root.join('config/ccms/means_entity_configs')

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
        super()
        @options = options
        @submission = submission
        @legal_aid_application = submission.legal_aid_application
        @transaction_time_stamp = Time.current.to_s(:ccms_date_time)
        @ccms_attribute_keys = attribute_configuration
      end

      def call
        save_request(@options[:case_type]) unless Rails.env.production?
        soap_client.call(:create_case_application, xml: request_xml) unless @options[:no_call]
      end

      private

      def means_entity_configs
        YAML.load_file(means_entity_config_file).map(&:deep_symbolize_keys!)
      end

      def means_entity_config_file
        MEANS_ENTITY_CONFIG_DIR.join('passported.yml')
      end

      def valuables_present?
        valuables.present?
      end

      def bank_accounts_present?
        bank_accounts.present?
      end

      def vehicles_present?
        vehicle.present?
      end

      def submission_case_ccms_reference
        @submission.case_ccms_reference
      end

      def attribute_configuration
        AttributeConfiguration.new(application_type: :standard).config
      end

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
        xml.__send__('ns6:Language', 'ENG')
        xml.__send__('ns6:UserLoginID', provider.username)
        xml.__send__('ns6:UserRole', 'EXTERNAL')
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
        xml.__send__('ns2:PreferredAddress', 'CLIENT')
        xml.__send__('ns2:ProviderDetails') { generate_provider_details(xml) }
        xml.__send__('ns2:CategoryOfLaw') { generate_category_of_law(xml) }
        xml.__send__('ns2:OtherParties') { generate_other_parties(xml) }
        xml.__send__('ns2:Proceedings') { generate_proceedings(xml) }
        xml.__send__('ns2:MeansAssesments') { generate_means_assessment(xml) }
        xml.__send__('ns2:MeritsAssesments') { generate_merits_assessment(xml) }
        xml.__send__('ns2:DevolvedPowersDate', @legal_aid_application.used_delegated_functions_on.to_s(:ccms_date)) if @legal_aid_application.used_delegated_functions?
        xml.__send__('ns2:ApplicationAmendmentType', @legal_aid_application.used_delegated_functions? ? 'SUBDP' : 'SUB')
        xml.__send__('ns2:LARDetails') { generate_lar_details(xml) }
      end

      def generate_case_docs(xml)
        @submission.submission_documents.each do |document|
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
              xml.__send__('ns2:OrganizationName', '.')
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
        xml.__send__('ns0:DateCreated', Time.current.to_s(:ccms_date_time))
        xml.__send__('ns0:LastUpdatedBy') do
          xml.__send__('ns0:UserLoginID', provider.username)
          xml.__send__('ns0:UserName', provider.username)
          xml.__send__('ns0:UserType', 'EXTERNAL')
        end
        xml.__send__('ns0:DateLastUpdated', Time.current.to_s(:ccms_date_time))
      end

      def generate_lar_details(xml)
        xml.__send__('ns2:LARScopeFlag', true)
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
          xml.__send__('ns0:UserLoginID', provider.contact_id)
        end
      end

      def generate_category_of_law(xml)
        xml.__send__('ns2:CategoryOfLawCode', @legal_aid_application.lead_proceeding_type.ccms_category_law_code)
        xml.__send__('ns2:CategoryOfLawDescription', @legal_aid_application.lead_proceeding_type.ccms_category_law)
        xml.__send__('ns2:RequestedAmount', as_currency(@legal_aid_application.default_cost_limitation))
      end

      def generate_proceedings(xml)
        @legal_aid_application.application_proceeding_types.each { |apt| generate_proceeding(xml, apt) }
      end

      def generate_proceeding(xml, application_proceeding_type)
        xml.__send__('ns2:Proceeding') do
          xml.__send__('ns2:ProceedingCaseID', application_proceeding_type.proceeding_case_p_num)
          xml.__send__('ns2:Status', 'Draft')
          xml.__send__('ns2:LeadProceedingIndicator', application_proceeding_type.lead_proceeding)
          xml.__send__('ns2:ProceedingDetails') { generate_proceeding_type(xml, application_proceeding_type) }
        end
      end

      def generate_proceeding_type(xml, application_proceeding_type)
        proceeding_type = application_proceeding_type.proceeding_type
        xml.__send__('ns2:ProceedingType', proceeding_type.ccms_code)
        xml.__send__('ns2:ProceedingDescription', proceeding_type.description)
        xml.__send__('ns2:MatterType', proceeding_type.ccms_matter_code)
        xml.__send__('ns2:LevelOfService', proceeding_type.default_level_of_service.service_level_number)
        xml.__send__('ns2:Stage', 8) # TODO: CCMS placeholder - this may need changing when multiple proceedings are introduced
        xml.__send__('ns2:ClientInvolvementType', 'A')
        xml.__send__('ns2:ScopeLimitations') { generate_scope_limitations(xml, application_proceeding_type) }
      end

      def generate_scope_limitations(xml, application_proceeding_type)
        application_proceeding_type.assigned_scope_limitations.each { |limitation| generate_scope_limitation(xml, limitation) }
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
          xml.__send__('ns0:Attribute', 'CLIENT_PROV_LA')
          xml.__send__('ns0:AttributeValue', true)
        end
      end

      def generate_means_assessment_details(xml)
        xml.__send__('ns0:AssessmentScreens') do
          xml.__send__('ns0:ScreenName', 'SUMMARY')
          sequence_no = 1
          means_entity_configs.each do |config|
            if predicate_true?(config)
              generate_entity_from_config(xml, sequence_no, config)
              sequence_no += 1
            end
          end
        end
      end

      def predicate_true?(config)
        return true if config[:predicate].blank?
        return config[:predicate] if boolean?(config[:predicate])

        __send__(config[:predicate])
      end

      def generate_entity_from_config(xml, sequence_no, config)
        config[:resolved_instance_label] = resolve_instance_label(config)
        xml.__send__('ns0:Entity') do
          __send__(config[:method], xml, sequence_no, config)
        end
      end

      def resolve_instance_label(config)
        return nil if config[:instance_label].nil?

        return config[:instance_label] unless config[:instance_label].starts_with?('#')

        method_name = config[:instance_label].sub(/^#/, '')
        __send__(method_name)
      end

      def generate_valuable_possessions_entity(xml, sequence_no, config)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', config[:entity_name])
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', config[:instance_label])
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, config[:yaml_section]) }
        end
      end

      def generate_bank_accounts_entity(xml, sequence_no, config)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', config[:entity_name])
        bank_accounts.each_with_index { |acct, index| generate_bank_account_instance(xml, acct, config, index) }
      end

      def generate_bank_account_instance(xml, bank_account, config, index)
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', bank_account.ccms_instance_name(index))
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, config[:yaml_section], bank_acct: bank_account) }
          # xml.__send__('ns0:Attributes') { generate_attributes_for(xml, config[:yaml_section], bank_acct: bank_account) }
        end
      end

      def generate_vehicles_entity(xml, sequence_no, config)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', config[:entity_name])
        generate_vehicle_instance(xml, vehicle, config) if vehicle
      end

      def generate_vehicle_instance(xml, vehicle, config)
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', config[:instance_label])
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, config[:yaml_section], vehicle: vehicle) }
          # xml.__send__('ns0:Attributes') { generate_attributes_for(xml, config[:yaml_section], vehicle: vehicle) }
        end
      end

      def generate_means_proceeding_entity(xml, sequence_no, config)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', config[:entity_name])
        application_proceeding_types.reverse_each do |application_proceeding_type|
          generate_means_proceeding_instance(xml, application_proceeding_type, config)
        end
      end

      def generate_means_proceeding_instance(xml, application_proceeding_type, config)
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', application_proceeding_type.proceeding_case_p_num)
          xml.__send__('ns0:Attributes') do
            EntityAttributesGenerator.call(self,
                                           xml,
                                           config[:yaml_section],
                                           appl_proceeding_type: application_proceeding_type,
                                           proceeding: application_proceeding_type.proceeding_type)
          end
        end
      end

      def generate_entity(xml, sequence_no, config)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', config[:entity_name])
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', config[:resolved_instance_label])
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, config[:yaml_section]) }
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
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, :global_merits) }
        end
      end

      # :nocov:
      def generate_merits_proceeding_entity(xml, sequence_no)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', 'PROCEEDING')
        application_proceeding_types.reverse_each { |apt| generate_merits_proceeding_instance(xml, apt) }
      end
      # :nocov:

      def generate_merits_proceeding_instance(xml, application_proceeding_type)
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', application_proceeding_type.proceeding_case_p_num)
          xml.__send__('ns0:Attributes') do
            EntityAttributesGenerator.call(self,
                                           xml,
                                           :proceeding_merits,
                                           appl_proceeding_type: application_proceeding_type,
                                           proceeding: application_proceeding_type.proceeding_type,
                                           opponent: @legal_aid_application.opponent,
                                           chances_of_success: application_proceeding_type.chances_of_success)
          end
        end
      end

      def generate_opponent_other_parties(xml, sequence_no)
        xml.__send__('ns0:SequenceNumber', sequence_no)
        xml.__send__('ns0:EntityName', 'OPPONENT_OTHER_PARTIES')
        xml.__send__('ns0:Instances') do
          xml.__send__('ns0:InstanceLabel', 'OPPONENT_7713451')
          xml.__send__('ns0:Attributes') { EntityAttributesGenerator.call(self, xml, :opponent_other_parties_merits) }
        end
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

      def valuables
        @valuables ||= @legal_aid_application.other_assets_declaration.valuable_items_value
      end

      def as_currency(raw_value)
        format('%<amount>.2f', amount: raw_value)
      end

      def boolean?(val)
        val.is_a?(TrueClass) || val.is_a?(FalseClass)
      end
    end
  end
end
