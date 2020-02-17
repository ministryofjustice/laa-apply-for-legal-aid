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
        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:merits_assessment) { legal_aid_application.merits_assessment }

        context 'family prospects' do
          context '50% or better' do
            before { merits_assessment.update! success_prospect: 'likely' }
            let(:expected_results) do
              [
                ['FAM_PROSP_50_OR_BETTER', true],
                ['FAM_PROSP_BORDER_UNCERT_POOR', false],
                ['FAM_PROSP_MARGINAL', false],
                ['FAM_PROSP_POOR', false],
                ['FAM_PROSP_UNCERTAIN', false]
              ]
            end
            it 'generates the correct values for the attributes' do
              expected_results.each do |expected_result_array|
                attr_name, expected_result = expected_result_array
                block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
                expect(block).to have_boolean_response expected_result
                expect(block).not_to(be_user_defined)
              end
            end
          end

          context 'marginal' do
            before { merits_assessment.update! success_prospect: 'marginal' }
            let(:expected_results) do
              [
                ['FAM_PROSP_50_OR_BETTER', false],
                ['FAM_PROSP_BORDER_UNCERT_POOR', false],
                ['FAM_PROSP_MARGINAL', true],
                ['FAM_PROSP_POOR', false],
                ['FAM_PROSP_UNCERTAIN', false]
              ]
            end
            it 'generates the correct values for the attributes' do
              expected_results.each do |expected_result_array|
                attr_name, expected_result = expected_result_array
                block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
                expect(block).to have_boolean_response expected_result
                expect(block).not_to(be_user_defined)
              end
            end
          end

          context 'poor' do
            before { merits_assessment.update! success_prospect: 'poor' }
            let(:expected_results) do
              [
                ['FAM_PROSP_50_OR_BETTER', false],
                ['FAM_PROSP_BORDER_UNCERT_POOR', false],
                ['FAM_PROSP_MARGINAL', false],
                ['FAM_PROSP_POOR', true],
                ['FAM_PROSP_UNCERTAIN', false]
              ]
            end
            it 'generates the correct values for the attributes' do
              expected_results.each do |expected_result_array|
                attr_name, expected_result = expected_result_array
                block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
                expect(block).to have_boolean_response expected_result
                expect(block).not_to(be_user_defined)
              end
            end
          end

          context 'borderline' do
            before { merits_assessment.update! success_prospect: 'borderline' }
            let(:expected_results) do
              [
                ['FAM_PROSP_50_OR_BETTER', false],
                ['FAM_PROSP_BORDER_UNCERT_POOR', true],
                ['FAM_PROSP_MARGINAL', false],
                ['FAM_PROSP_POOR', false],
                ['FAM_PROSP_UNCERTAIN', false]
              ]
            end
            it 'generates the correct values for the attributes' do
              expected_results.each do |expected_result_array|
                attr_name, expected_result = expected_result_array
                block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
                expect(block).to have_boolean_response expected_result
                expect(block).not_to(be_user_defined)
              end
            end
          end

          context 'not_known' do
            before { merits_assessment.update! success_prospect: 'not_known' }
            let(:expected_results) do
              [
                ['FAM_PROSP_50_OR_BETTER', false],
                ['FAM_PROSP_BORDER_UNCERT_POOR', false],
                ['FAM_PROSP_MARGINAL', false],
                ['FAM_PROSP_POOR', false],
                ['FAM_PROSP_UNCERTAIN', true]
              ]
            end
            it 'generates the correct values for the attributes' do
              expected_results.each do |expected_result_array|
                attr_name, expected_result = expected_result_array
                block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
                expect(block).to have_boolean_response expected_result
                expect(block).not_to(be_user_defined)
              end
            end
          end
        end
      end
    end
  end
end
