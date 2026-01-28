require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe NonPassportedCaseAddRequestor, :ccms do
      describe "XML request" do
        let(:expected_tx_id) { "201904011604570390059770666" }
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

        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }

        before do
          create(:chances_of_success, :with_optional_text, proceeding:)
          create(:cfe_v3_result, submission: cfe_submission)
        end

        it "generates the expected block for each of the hard coded attrs" do
          hard_coded_attrs.each do |attr|
            entity, attr_name, type, user_defined, value = attr
            block = XmlExtractor.call(xml, entity.to_sym, attr_name)
            case type
            when "number"
              expect(block).to have_number_response value.to_i
            when "text"
              expect(block).to have_text_response value
            when "currency"
              expect(block).to have_currency_response value
            when "date"
              expect(block).to have_date_response value
            else raise "Unexpected type"
            end

            case user_defined
            when true
              expect(block).to be_user_defined
            else
              expect(block).not_to be_user_defined
            end
          end
        end

        def hard_coded_attrs
          [
            ["additional_property", "ADDPROPERTY_INPUT_N_4WP2_12A", "number", true, "0"],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_10A", "text", true, "."],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_11A", "text", true, "Bungalow"],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_15A", "text", true, "Vacant Occupation"],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_5A", "text", true, "."],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_6A", "text", true, "."],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_7A", "text", true, "."],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_8A", "text", true, "."],
            ["additional_property", "ADDPROPERTY_INPUT_T_4WP2_9A", "text", true, "United Kingdom"],
            ["first_bank_acct_instance", "BANKACC_INPUT_C_7WP2_18A", "currency", true, "0"],
            ["first_bank_acct_instance", "BANKACC_INPUT_N_7WP2_5A", "text", true, "0"],
            ["first_bank_acct_instance", "BANKACC_INPUT_T_7WP2_4A", "text", true, "."],
            ["first_bank_acct_instance", "BANKACC_INPUT_T_7WP2_6A", "text", true, "Client Sole"],
            ["change_in_circumstance", "CHANGE_CIRC_INPUT_T_33WP3_6A", "text", true, "."],
            ["cli_capital", "CLICAPITAL_INPUT_T_9WP2_12A", "text", true, "."],
            ["global_means", "GB_INPUT_B_13WP3_49A", "text", true, "None of the above"],
            ["global_means", "MARITIAL_STATUS", "text", true, "U"],
            ["global_means", "MEANS_OPA_RELEASE", "text", false, "12.2"],
            ["global_means", "MEANS_ROUTING", "text", false, "MANB"],
            ["global_means", "POA_OR_BILL_FLAG", "text", true, "N/A"],
            ["global_means", "RB_VERSION_DATE_MEANS", "date", false, "29-11-2019"],
            ["global_means", "RB_VERSION_NUMBER_MEANS", "text", false, "v2.31.6"],
            ["global_merits", "_SYSTEM_PUI_CONTEXT", "text", true, "Unused"],
            ["global_merits", "_SYSTEM_PUI_URL", "text", true, "Unused"],
            ["global_merits", "LEGAL_HELP_COSTS_TO_DATE", "currency", false, "0"],
            ["global_merits", "MERITS_OPA_RELEASE", "text", false, "12.2"],
            ["global_merits", "MERITS_ROUTING_NAME", "text", false, "Standard Family Merits"],
            ["global_merits", "PRE_CERT_COSTS", "currency", false, "0"],
            ["global_merits", "RB_VERSION_DATE_MERITS", "date", false, "10-10-2019"],
            ["global_merits", "RB_VERSION_NUMBER_MERITS", "text", false, "LAR v5.15.10"],
            ["land", "LAND_INPUT_N_3WP2_18A", "number", true, "100"],
            ["land", "LAND_INPUT_T_5WP2_10A", "text", true, "."],
            ["land", "LAND_INPUT_T_5WP2_5A", "text", true, "."],
            ["land", "LAND_INPUT_T_5WP2_6A", "text", true, "."],
            ["land", "LAND_INPUT_T_5WP2_7A", "text", true, "."],
            ["land", "LAND_INPUT_T_5WP2_8A", "text", true, "."],
            ["land", "LAND_INPUT_T_5WP2_9A", "text", true, "United Kingdom"],
            ["life_assurance", "LIFEASSUR_INPUT_T_13WP2_12A", "text", true, "."],
            ["life_assurance", "LIFEASSUR_INPUT_T_13WP2_14A", "text", true, "Client Sole"],
            ["life_assurance", "LIFEASSUR_INPUT_T_13WP2_15A", "text", true, "Loan Value"],
            ["life_assurance", "LIFEASSUR_INPUT_T_13WP2_19A", "text", true, "."],
            ["main_third", "MAINTHIRD_INPUT_T_3WP2_12A", "text", true, "."],
            ["main_third", "MAINTHIRD_INPUT_T_3WP2_13A", "text", true, "Other"],
            ["money_due", "MONEYDUE_INPUT_T_15WP2_13A", "text", true, "debtor"],
            ["other_capital", "OTHCAPITAL_INPUT_T_17WP2_13A", "text", true, "."],
            ["other_savings", "OTHERSAVING_INPUT_C_10WP2_11A", "currency", true, "0"],
            ["other_savings", "OTHERSAVING_INPUT_T_10WP2_18A", "text", true, "0"],
            ["other_savings", "OTHERSAVING_INPUT_T_10WP2_3A", "text", true, "."],
            ["other_savings", "OTHERSAVING_INPUT_T_10WP2_5A", "text", true, "Client Sole"],
            ["cli_premium", "CLIPREMIUM_INPUT_T_9WP2_12A", "text", true, "."],
            ["proceeding_means", "PROC_UPPER_TRIBUNAL", "text", false, "No"],
            ["proceeding_merits", "CLIENT_INVOLVEMENT", "text", false, "Applicant/Claimant/Petitioner"],
            ["proceeding_merits", "DAMAGES_AGAINST_POLICE", "text", false, "No"],
            ["proceeding_merits", "DISBURSEMENT_COST_FAMILY", "currency", true, "0"],
            ["proceeding_merits", "DOM_VIOLENCE_WAIVER_APPLIES", "text", false, "Yes"],
            ["proceeding_merits", "EXPERT_COST_FAMILY", "currency", true, "0"],
            ["proceeding_merits", "IMMIGRATION_QUESTION_APPLIES", "text", false, "No"],
            ["proceeding_merits", "MATRIMONIAL_PROCEEDING", "text", false, "No"],
            ["proceeding_merits", "MATTER_TYPE_CHILD_ABDUCTION", "text", false, "No"],
            ["proceeding_merits", "MATTER_TYPE_PRIVATE_FAMILY", "text", false, "Yes"],
            ["proceeding_merits", "MATTER_TYPE_PUBLIC_FAMILY", "text", false, "No"],
            ["proceeding_merits", "MATTER_TYPE_STAND_ALONE", "text", false, "No"],
            ["proceeding_merits", "NEW_OR_EXISTING_MERITS", "text", false, "NEW"],
            ["proceeding_merits", "PRIVATE_FUNDING_CONSIDERED", "text", false, "No"],
            ["proceeding_merits", "PROC_AVAILABLE_AMENDMENT_ONLY", "text", false, "No"],
            ["proceeding_merits", "PROC_CARE_SUPERV_OR_RELATED", "text", false, "No"],
            ["proceeding_merits", "PROC_CHILD_ABDUCTION", "text", false, "No"],
            ["proceeding_merits", "PROC_DEFAULT_LEVEL_OF_SERVICE", "text", false, "3"],
            ["proceeding_merits", "PROC_FIN_REP_CATEGORY", "text", false, "Domestic Violence"],
            ["proceeding_merits", "PROC_INVOLVING_CHILDREN", "text", false, "No"],
            ["proceeding_merits", "PROC_INVOLVING_FIN_AND_PROP", "text", false, "No"],
            ["proceeding_merits", "PROC_INVOLVING_INJUNCTION", "text", false, "Yes"],
            ["proceeding_merits", "PROC_IS_MERITS_TESTED", "text", false, "Yes"],
            ["proceeding_merits", "PROC_IS_SCA_OR_RELATED", "text", false, "No"],
            ["proceeding_merits", "PROC_POSSESSION", "text", false, "No"],
            ["proceeding_merits", "PROC_REGISTER_FOREIGN_ORDER", "text", false, "No"],
            ["proceeding_merits", "PROC_SUBJECT_TO_DP_CHECK", "text", false, "Yes"],
            ["proceeding_merits", "PROC_SUBJECT_TO_MEDIATION", "text", false, "Yes"],
            ["proceeding_merits", "PROCEEDING_INCLUDES_CHILD", "text", false, "No"],
            ["proceeding_merits", "PROCEEDING_STAND_ALONE", "text", false, "No"],
            ["proceeding_merits", "PROCEEDING_TYPE", "text", false, "proc error"],
            ["proceeding_merits", "PROPORTIONALITY_QUESTION", "text", false, "Yes"],
            ["proceeding_merits", "ROUTING_FOR_PROCEEDING", "text", false, "Standard Family Merits"],
            ["proceeding_merits", "SMOD_APPLICABLE", "text", false, "No"],
            ["third_party_acct", "THIRDPARTACC_INPUT_N_8WP2_5A", "text", true, "."],
            ["third_party_acct", "THIRDPARTACC_INPUT_T_8WP2_3A", "text", true, "."],
            ["third_party_acct", "THIRDPARTACC_INPUT_T_8WP2_4A", "text", true, "."],
            ["third_party_acct", "THIRDPARTACC_INPUT_T_8WP2_6A", "text", true, "Other Relative"],
            ["third_party_acct", "THIRDPARTACC_INPUT_T_8WP2_7A", "text", true, "Other Relative"],
            ["timeshare", "TIMESHARE_INPUT_C_6WP2_12A", "currency", true, "0"],
            ["timeshare", "TIMESHARE_INPUT_C_6WP2_13A", "currency", true, "0"],
            ["timeshare", "TIMESHARE_INPUT_N_6WP2_14A", "number", true, "100"],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_10A", "text", true, "."],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_5A", "text", true, "."],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_6A", "text", true, "."],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_7A", "text", true, "."],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_8A", "text", true, "."],
            ["timeshare", "TIMESHARE_INPUT_T_6WP2_9A", "text", true, "United Kingdom"],
            ["trust", "TRUST_INPUT_T_16WP2_12A", "text", true, "Interest realised upon a specific event occuring"],
            ["valuable_possessions", "VALPOSSESS_INPUT_T_12WP2_7A", "text", true, "."],
            ["will", "WILL_INPUT_T_2WP2_52A", "text", true, "."],
          ]
        end
      end
    end
  end
end
