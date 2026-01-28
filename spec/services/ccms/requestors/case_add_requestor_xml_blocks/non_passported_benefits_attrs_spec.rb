require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe NonPassportedCaseAddRequestor, :ccms do
      describe "XML request" do
        let(:expected_tx_id) { "201904011604570390059770666" }
        let(:proceeding_type) { legal_aid_application.application_proceeding_types.first.proceeding_type }
        let(:firm) { create(:firm, name: "Firm1") }
        let(:office) { create(:office, firm:) }
        let(:savings_amount) { legal_aid_application.savings_amount }
        let(:other_assets_decl) { legal_aid_application.other_assets_declaration }
        let(:provider) do
          create(:provider,
                 firm:,
                 selected_office: office,
                 username: 4_953_649)
        end

        let(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_applicant_and_address,
                 :with_negative_benefit_check_result,
                 :with_proceedings,
                 :with_merits_submitted,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider:,
                 office:)
        end
        let!(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:applicant) { legal_aid_application.applicant }

        before do
          create(:chances_of_success, :with_optional_text, proceeding:)
          create(:cfe_v3_result, submission: cfe_submission)
        end

        describe "boolean attributes" do
          # these are all currently coded as FALSE until such time as we can determine which benefits are received
          it "generates the attribute blocks as false" do
            boolean_benefit_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :global_means, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "value_attributes" do
          # These are all omitted until such time sa we can determine which benefits are received

          it "omits all attributes" do
            value_benefit_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :global_means, attr_name)
              expect(block).not_to be_present
            end
          end
        end

        def boolean_benefit_attrs
          %w[
            GB_INPUT_B_21WP3_389A
            GB_INPUT_B_6WP3_232A
            GB_INPUT_B_6WP3_234A
            GB_INPUT_B_6WP3_235A
            GB_INPUT_B_6WP3_236A
            GB_INPUT_B_6WP3_237A
            GB_INPUT_B_6WP3_238A
            GB_INPUT_B_6WP3_239A
            GB_INPUT_B_6WP3_241A
            GB_INPUT_B_6WP3_254A
          ]
        end

        def value_benefit_attrs
          %w[
            GB_INPUT_C_6WP3_228A
            GB_INPUT_C_6WP3_318A
            GB_INPUT_C_6WP3_319A
          ]
        end
      end
    end
  end
end
