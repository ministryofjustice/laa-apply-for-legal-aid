require_relative "../payload_generators/entity_attributes_generator"

module CCMS
  module Requestors
    class CaseAddRequestor < BaseRequestor
      include CCMS::PayloadGenerators

      attr_reader :ccms_attribute_keys, :submission

      delegate :involved_children,
               :opponents, to: :legal_aid_application

      attr_accessor :legal_aid_application

      MEANS_ENTITY_CONFIG_DIR = Rails.root.join("config/ccms/means_entity_configs")

      wsdl_from Rails.configuration.x.ccms_soa.caseServicesWsdl

      def initialize(submission, options)
        super()
        @options = options
        @submission = submission
        @legal_aid_application = submission.legal_aid_application
        @transaction_time_stamp = Time.current.to_fs(:ccms_date_time)
        @ccms_attribute_keys = attribute_configuration
      end

      def call
        save_request(@options[:case_type]) unless Rails.env.production?
        Faraday::SoapCall.new(wsdl_location, :ccms).call(request_xml)
      end

    private

      def means_entity_configs
        YAML.load_file(means_entity_config_file).map(&:deep_symbolize_keys!)
      end

      def means_entity_config_file
        MEANS_ENTITY_CONFIG_DIR.join("passported.yml")
      end

      def not_nil_or_zero?(value)
        value.present? && value.nonzero?
      end

      def valuables_present?
        valuables.present?
      end

      def bank_accounts_present?
        bank_accounts.present?
      end

      def submission_case_ccms_reference
        @submission.case_ccms_reference
      end

      def attribute_configuration
        AttributeConfiguration.new(application_type: :standard).config
      end

      # :nocov:
      def save_request(case_type)
        Rails.root.join("ccms_integration/generated/add_#{case_type}_case_request.xml").open("w") do |fp|
          fp.puts request_xml
        end
      end
      # :nocov:

      def request_xml
        @request_xml ||= soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__(:"casebim:CaseAddRQ") do
          xml.__send__(:"hdr:HeaderRQ") { header_request(xml) }
          xml.__send__(:"casebim:Case") { case_request(xml) }
        end
      end

      def header_request(xml)
        xml.__send__(:"hdr:TransactionRequestID", transaction_request_id)
        xml.__send__(:"hdr:Language", "ENG")
        xml.__send__(:"hdr:UserLoginID", provider.username)
        xml.__send__(:"hdr:UserRole", "EXTERNAL")
      end

      def case_request(xml)
        xml.__send__(:"casebio:CaseReferenceNumber", @submission.case_ccms_reference)
        xml.__send__(:"casebio:CaseDetails") do
          xml.__send__(:"casebio:ApplicationDetails") { generate_application_details(xml) }
          xml.__send__(:"casebio:LinkedCases") { generate_linked_cases(xml) }
          xml.__send__(:"casebio:RecordHistory") { generate_record_history(xml) }
          xml.__send__(:"casebio:CaseDocs") { generate_case_docs(xml) }
        end
      end

      def generate_application_details(xml)
        xml.__send__(:"casebio:Client") { generate_client(xml) }
        xml.__send__(:"casebio:PreferredAddress", "CASE")
        xml.__send__(:"casebio:CorrespondenceAddress") { generate_correspondence_address(xml) }
        xml.__send__(:"casebio:ProviderDetails") { generate_provider_details(xml) }
        xml.__send__(:"casebio:CategoryOfLaw") { generate_category_of_law(xml) }
        xml.__send__(:"casebio:OtherParties") { generate_other_parties(xml) }
        xml.__send__(:"casebio:Proceedings") { generate_proceedings(xml) }
        xml.__send__(:"casebio:MeansAssesments") { generate_means_assessment(xml) }
        xml.__send__(:"casebio:MeritsAssesments") { generate_merits_assessment(xml) }
        xml.__send__(:"casebio:DevolvedPowersDate", @legal_aid_application.used_delegated_functions_on.to_fs(:ccms_date)) if @legal_aid_application.non_sca_used_delegated_functions?
        xml.__send__(:"casebio:ApplicationAmendmentType", generate_application_amendment_type)
        xml.__send__(:"casebio:LARDetails") { generate_lar_details(xml) }
      end

      def generate_linked_cases(xml)
        LinkedApplication.where(associated_application_id: @legal_aid_application.id).find_each do |linked_application|
          xml.__send__(:"casebio:LinkedCase") do
            xml.__send__(:"casebio:CaseReferenceNumber", linked_application.lead_application.case_ccms_reference)
            xml.__send__(:"casebio:LinkType", linked_application.link_type_code)
          end
        end
      end

      def generate_case_docs(xml)
        @submission.submission_documents.each do |document|
          xml.__send__(:"casebio:CaseDoc") do
            xml.__send__(:"casebio:CCMSDocumentID", document.ccms_document_id)
            xml.__send__(:"casebio:DocumentSubject", document.document_type)
          end
        end
      end

      def generate_other_parties(xml)
        @legal_aid_application.opponents.order(:created_at).each do |opponent|
          OtherPartyAttributeGenerator.call(xml, opponent)
        end

        @legal_aid_application.involved_children.order(:date_of_birth).each do |child|
          OtherPartyAttributeGenerator.call(xml, child)
        end
      end

      def generate_record_history(xml)
        xml.__send__(:"common:DateCreated", Time.current.to_fs(:ccms_date_time))
        xml.__send__(:"common:LastUpdatedBy") do
          xml.__send__(:"common:UserLoginID", provider.username)
          xml.__send__(:"common:UserName", provider.username)
          xml.__send__(:"common:UserType", "EXTERNAL")
        end
        xml.__send__(:"common:DateLastUpdated", Time.current.to_fs(:ccms_date_time))
      end

      def generate_lar_details(xml)
        xml.__send__(:"casebio:LARScopeFlag", true)
      end

      def generate_application_amendment_type
        if @legal_aid_application.non_sca_used_delegated_functions?
          "SUBDP"
        else
          "SUB"
        end
      end

      def generate_client(xml)
        xml.__send__(:"casebio:ClientReferenceNumber", @submission.applicant_ccms_reference)
        xml.__send__(:"casebio:FirstName", applicant.first_name)
        xml.__send__(:"casebio:Surname", applicant.last_name)
      end

      def generate_provider_details(xml)
        xml.__send__(:"casebio:ProviderFirmID", provider.firm.ccms_id)
        xml.__send__(:"casebio:ProviderOfficeID", @legal_aid_application.office.ccms_id)
        xml.__send__(:"casebio:ContactUserID") do
          xml.__send__(:"common:UserLoginID", provider.ccms_contact_id)
        end
      end

      def generate_correspondence_address(xml)
        xml.__send__(:"common:CoffName", applicant.correspondence_address_for_ccms.care_of_recipient) unless applicant.correspondence_address_for_ccms.care_of_recipient.nil?
        xml.__send__(:"common:AddressLine1", applicant.correspondence_address_for_ccms.address_line_one)
        xml.__send__(:"common:AddressLine2", applicant.correspondence_address_for_ccms.address_line_two)
        xml.__send__(:"common:AddressLine3", applicant.correspondence_address_for_ccms.address_line_three) unless applicant.correspondence_address_for_ccms.address_line_three.nil?
        xml.__send__(:"common:City", applicant.correspondence_address_for_ccms.city)
        xml.__send__(:"common:County", applicant.correspondence_address_for_ccms.county)
        xml.__send__(:"common:Country", "GBR")
        xml.__send__(:"common:PostalCode", applicant.correspondence_address_for_ccms.pretty_postcode) if applicant.correspondence_address_for_ccms.postcode.present?
      end

      def generate_category_of_law(xml)
        xml.__send__(:"casebio:CategoryOfLawCode", @legal_aid_application.lead_proceeding.category_law_code)
        xml.__send__(:"casebio:CategoryOfLawDescription", @legal_aid_application.lead_proceeding.category_of_law)
        xml.__send__(:"casebio:RequestedAmount", as_currency(@legal_aid_application.substantive_cost_limitation))
      end

      def generate_proceedings(xml)
        @legal_aid_application.proceedings.each { |proceeding| generate_proceeding(xml, proceeding) }
      end

      def generate_proceeding(xml, proceeding)
        xml.__send__(:"casebio:Proceeding") do
          xml.__send__(:"casebio:ProceedingCaseID", proceeding.case_p_num)
          xml.__send__(:"casebio:Status", "Draft")
          xml.__send__(:"casebio:LeadProceedingIndicator", proceeding.lead_proceeding)
          xml.__send__(:"casebio:ProceedingDetails") { generate_proceeding_type(xml, proceeding) }
        end
      end

      def generate_proceeding_type(xml, proceeding)
        xml.__send__(:"casebio:ProceedingType", proceeding.ccms_code)
        xml.__send__(:"casebio:ProceedingDescription", proceeding.description)
        xml.__send__(:"casebio:MatterType", proceeding.ccms_matter_code)
        xml.__send__(:"casebio:LevelOfService", proceeding.substantive_level_of_service)
        xml.__send__(:"casebio:Stage", proceeding.substantive_level_of_service_stage)
        xml.__send__(:"casebio:ClientInvolvementType", proceeding.client_involvement_type_ccms_code)
        xml.__send__(:"casebio:ScopeLimitations") { generate_scope_limitations(xml, proceeding) }
      end

      def generate_scope_limitations(xml, proceeding)
        proceeding.substantive_scope_limitations.each do |scope_limitation|
          xml.__send__(:"casebio:ScopeLimitation") do
            xml.__send__(:"casebio:ScopeLimitation", scope_limitation.code)
            xml.__send__(:"casebio:ScopeLimitationWording", scope_limitation.description)
            xml.__send__(:"casebio:DelegatedFunctionsApply", false)
          end
        end
        return if proceeding.used_delegated_functions_on.nil?

        proceeding.emergency_scope_limitations.each do |scope_limitation|
          xml.__send__(:"casebio:ScopeLimitation") do
            xml.__send__(:"casebio:ScopeLimitation", scope_limitation.code)
            xml.__send__(:"casebio:ScopeLimitationWording", scope_limitation.description)
            xml.__send__(:"casebio:DelegatedFunctionsApply", true)
          end
        end
      end

      def generate_means_assessment(xml)
        xml.__send__(:"casebio:AssesmentResults") do
          xml.__send__(:"common:Results") { generate_means_assessment_results(xml) }
          xml.__send__(:"common:AssesmentDetails") { generate_means_assessment_details(xml) }
        end
      end

      def generate_means_assessment_results(xml)
        xml.__send__(:"common:Goal") do
          xml.__send__(:"common:Attribute", "CLIENT_PROV_LA")
          xml.__send__(:"common:AttributeValue", true)
        end
      end

      def generate_means_assessment_details(xml)
        xml.__send__(:"common:AssessmentScreens") do
          xml.__send__(:"common:ScreenName", "SUMMARY")
          sequence_no = 1
          means_entity_configs.each do |config|
            if predicate_true?(config)
              generate_entity_from_config(xml, sequence_no, config)
              sequence_no += 1
            end
          end
        end
      end

      def generate_opponent_other_parties_means_entity(xml, sequence_no, config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", "OPPONENT_OTHER_PARTIES")
        other_parties.each { |other_party| generate_opponent_other_parties_means_instance(xml, other_party, config) }
      end

      def generate_opponent_other_parties_means_instance(xml, other_party, config)
        if other_party.ccms_child? || other_party.individual?
          generate_opponent_individual_means_instance(xml, other_party, config)
        else
          generate_opponent_organisation_means_instance(xml, other_party, config)
        end
      end

      def generate_opponent_individual_means_instance(xml, other_party, config)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self, xml, config[:yaml_section], other_party:)
          end
        end
      end

      def generate_opponent_organisation_means_instance(xml, other_party, config)
        if other_party.exists_in_ccms?
          generate_opponent_existing_organisation_means_instance(xml, other_party, config)
        else
          generate_opponent_new_organisation_means_instance(xml, other_party, config)
        end
      end

      def generate_opponent_existing_organisation_means_instance(xml, other_party, config)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", other_party.ccms_opponent_id)
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self, xml, config[:yaml_section], other_party:)
          end
        end
      end

      def generate_opponent_new_organisation_means_instance(xml, other_party, config)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self, xml, config[:yaml_section], other_party:)
          end
        end
      end

      def other_parties
        opponents.all + involved_children
      end

      def predicate_true?(config)
        return true if config[:predicate].blank?
        return config[:predicate] if boolean?(config[:predicate])

        __send__(config[:predicate])
      end

      def generate_entity_from_config(xml, sequence_no, config)
        config[:resolved_instance_label] = resolve_instance_label(config)
        xml.__send__(:"common:Entity") do
          __send__(config[:method], xml, sequence_no, config)
        end
      end

      def resolve_instance_label(config)
        return nil if config[:instance_label].nil?

        return config[:instance_label] unless config[:instance_label].starts_with?("#")

        method_name = config[:instance_label].sub(/^#/, "")
        __send__(method_name)
      end

      def generate_valuable_possessions_entity(xml, sequence_no, config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", config[:entity_name])
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", config[:instance_label])
          xml.__send__(:"common:Attributes") { EntityAttributesGenerator.call(self, xml, config[:yaml_section]) }
        end
      end

      def generate_bank_accounts_entity(xml, sequence_no, config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", config[:entity_name])
        bank_accounts.each_with_index { |acct, index| generate_bank_account_instance(xml, acct, config, index) }
      end

      def generate_bank_account_instance(xml, bank_account, config, index)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", bank_account.ccms_instance_name(index))
          xml.__send__(:"common:Attributes") { EntityAttributesGenerator.call(self, xml, config[:yaml_section], bank_acct: bank_account) }
        end
      end

      def generate_means_proceeding_entity(xml, sequence_no, config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", config[:entity_name])
        proceedings.reverse_each do |proceeding|
          generate_means_proceeding_instance(xml, proceeding, config)
        end
      end

      def generate_means_proceeding_instance(xml, proceeding, config)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", proceeding.case_p_num)
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self,
                                           xml,
                                           config[:yaml_section],
                                           proceeding:)
          end
        end
      end

      def generate_entity(xml, sequence_no, config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", config[:entity_name])
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", config[:resolved_instance_label])
          xml.__send__(:"common:Attributes") { EntityAttributesGenerator.call(self, xml, config[:yaml_section]) }
        end
      end

      def generate_merits_assessment(xml)
        xml.__send__(:"casebio:AssesmentResults") do
          xml.__send__(:"common:Results") { generate_merits_assessment_results(xml) }
          xml.__send__(:"common:AssesmentDetails") { generate_merits_assessment_details(xml) }
        end
      end

      def generate_merits_assessment_results(xml)
        xml.__send__(:"common:Goal") do
          xml.__send__(:"common:Attribute", "ASSESS_COMPLETE")
          xml.__send__(:"common:AttributeValue", true)
        end
      end

      def generate_merits_assessment_details(xml)
        xml.__send__(:"common:AssessmentScreens") do
          xml.__send__(:"common:ScreenName", "SUMMARY")
          xml.__send__(:"common:Entity") { generate_global_merits_entity(xml, 1) }
          xml.__send__(:"common:Entity") { generate_merits_proceeding_entity(xml, 2) }
          xml.__send__(:"common:Entity") { generate_opponent_other_parties_merits_entity(xml, 4) }
        end
      end

      def generate_global_merits_entity(xml, sequence_no)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", "global")
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", @submission.case_ccms_reference)
          xml.__send__(:"common:Attributes") { EntityAttributesGenerator.call(self, xml, :global_merits) }
        end
      end

      # :nocov:
      def generate_merits_proceeding_entity(xml, sequence_no)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", "PROCEEDING")
        proceedings.reverse_each { |proceeding| generate_merits_proceeding_instance(xml, proceeding) }
      end
      # :nocov:

      def generate_merits_proceeding_instance(xml, proceeding)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", proceeding.case_p_num)
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self,
                                           xml,
                                           :proceeding_merits,
                                           proceeding:,
                                           opponent: @legal_aid_application.opponents.first,
                                           chances_of_success: proceeding.chances_of_success)
          end
        end
      end

      def generate_client_residing_person_entity(xml, sequence_no, _config)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", "CLIENT_RESIDING_PERSON")
        @legal_aid_application.dependants.each_with_index { |dependant, index| generate_client_residing_person_instance(xml, dependant, index) }
      end

      def generate_client_residing_person_instance(xml, dependant, index)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", "the client's residing person#{index + 1}")
          xml.__send__(:"common:Attributes") { EntityAttributesGenerator.call(self, xml, :client_residing_person, dependant:) }
        end
      end

      def generate_opponent_other_parties_merits_entity(xml, sequence_no)
        xml.__send__(:"common:SequenceNumber", sequence_no)
        xml.__send__(:"common:EntityName", "OPPONENT_OTHER_PARTIES")
        other_parties.each { |other_party| generate_opponent_other_parties_instance_merits(xml, other_party) }
      end

      def generate_opponent_other_parties_instance_merits(xml, other_party)
        xml.__send__(:"common:Instances") do
          xml.__send__(:"common:InstanceLabel", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"common:Attributes") do
            EntityAttributesGenerator.call(self, xml, :opponent_other_parties_merits, other_party:)
          end
        end
      end

      def applicant
        @applicant ||= @legal_aid_application.applicant
      end

      def provider
        @provider ||= @legal_aid_application.merits_submitted_by
      end

      def proceedings
        @proceedings ||= @legal_aid_application.proceedings
      end

      def bank_accounts
        @bank_accounts ||= applicant.bank_accounts
      end

      def valuables
        @valuables ||= @legal_aid_application.other_assets_declaration.valuable_items_value
      end

      def as_currency(raw_value)
        sprintf("%<amount>.2f", amount: raw_value)
      end

      def boolean?(val)
        val.is_a?(TrueClass) || val.is_a?(FalseClass)
      end
    end
  end
end
