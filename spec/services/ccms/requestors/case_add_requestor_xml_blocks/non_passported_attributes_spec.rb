require 'rails_helper'

module CCMS
  module Requestors # rubocop:disable Metrics/ModuleLength
    RSpec.describe NonPassportedCaseAddRequestor do
      context 'XML request' do
        let(:expected_tx_id) { '201904011604570390059770666' }
        let(:proceeding_type) { create :proceeding_type, :with_real_data }
        let(:firm) { create :firm, name: 'Firm1' }
        let(:office) { create :office, firm: firm }
        let(:savings_amount) { legal_aid_application.savings_amount }
        let(:other_assets_decl) { legal_aid_application.other_assets_declaration }
        let(:provider) do
          create :provider,
                 firm: firm,
                 selected_office: office,
                 username: 4_953_649
        end

        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_applicant_and_address,
                 :with_negative_benefit_check_result,
                 :with_proceeding_types,
                 :with_substantive_scope_limitation,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 proceeding_types: [proceeding_type],
                 provider: provider,
                 office: office
        end

        let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
        let(:respondent) { legal_aid_application.respondent }
        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:success_prospect) { :likely }
        let(:merits_assessment) { create :merits_assessment, success_prospect: success_prospect, success_prospect_details: 'details' }

        # enable this context if you need to create a file of the payload for manual inspection
        # context 'saving to a temporary file', skip: 'Not needed for testing - but useful if you want to save the payload to a file' do
        context 'save to a temporary file' do
          it 'creates a file' do
            filename = Rails.root.join('tmp/generated_non_passported_ccms_payload.xml')
            File.open(filename, 'w') { |f| f.puts xml }
            expect(File.exist?(filename)).to be true
          end
        end

        context 'hard coded false attributes', skip: 'skip until all enities have been coded up' do
          it 'generates the block with boolean value set to false' do
            false_attributes.each do |config_spec|
              entity, attribute, user_defined_ind = config_spec
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response false
              if user_defined_ind == true
                expect(block).to be_user_defined
              else
                expect(block).to not_be_user_defined
              end
            end
          end
        end

        def false_attributes # rubocop:disable Metrics/MethodLength
          [
            [:proceeding_merits, 'ACTION_DAMAGES_AGAINST_POLICE', false],
            [:property_means, 'ADDPROPERTY_INFER_B_4WP2_52A', false],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_18A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_24A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_25A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_26A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_27A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_28A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_32A', true],
            [:property_means, 'ADDPROPERTY_INPUT_B_4WP2_32A', true]
          ]
        end
      end
    end
  end
end
