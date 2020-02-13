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
        let(:timestamp) { Time.now.strftime('%Y-%m-%d_%H.%M') }

        # enable this context if you need to create a file of the payload for manual inspection
        # context 'saving to a temporary file', skip: 'Not needed for testing - but useful if you want to save the payload to a file' do
        context 'save to a temporary file', skip: 'not needed for testing, but re-enable if you want to save the XML to a file' do
          it 'creates a file' do
            filename = Rails.root.join("tmp/generated_non_passported_ccms_payload_#{timestamp}.xml")
            File.open(filename, 'w') { |f| f.puts xml }
            expect(File.exist?(filename)).to be true
          end
        end

        context 'hard coded false attributes' do
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
            [:first_bank_acct_instance, 'BANKACC_INPUT_B_7WP2_12A', true],
            [:first_bank_acct_instance, 'BANKACC_INPUT_B_7WP2_14A', true],
            [:first_bank_acct_instance, 'BANKACC_INPUT_B_7WP2_16A', true],
            [:global_means, 'CLIENT_NASS', false],
            [:global_means, 'CLIENT_PRISONER', false],
            [:global_means, 'CLIENT_VULNERABLE', true],
            [:global_means, 'GB_INFER_B_26WP3_214A', false],
            [:global_means, 'GB_INPUT_B_12WP3_1A', true],
            [:global_means, 'GB_INPUT_B_13WP3_15A', false],
            [:global_means, 'GB_INPUT_B_13WP3_2A', false],
            [:global_means, 'GB_INPUT_B_13WP3_37A', false],
            [:global_means, 'GB_INPUT_B_13WP3_5A', true],
            [:global_means, 'GB_INPUT_B_13WP3_7A', false],
            [:global_means, 'GB_INPUT_B_1WP2_17A', true],
            [:global_means, 'GB_INPUT_B_1WP2_19A', true],
            [:global_means, 'GB_INPUT_B_1WP3_166A', true],
            [:global_means, 'GB_INPUT_B_1WP3_167A', true],
            [:global_means, 'GB_INPUT_B_1WP3_169A', true],
            [:global_means, 'GB_INPUT_B_1WP3_170A', true],
            [:global_means, 'GB_INPUT_B_1WP3_171A', true],
            [:global_means, 'GB_INPUT_B_1WP3_172A', true],
            [:global_means, 'GB_INPUT_B_1WP3_174A', true],
            [:global_means, 'GB_INPUT_B_1WP3_175A', false],
            [:global_means, 'GB_INPUT_B_1WP3_390A', true],
            [:global_means, 'GB_INPUT_B_1WP3_400A', false],
            [:global_means, 'GB_INPUT_B_1WP3_401A', false],
            [:global_means, 'GB_INPUT_B_2WP4_2A', true],
            [:global_means, 'GB_INPUT_B_9WP3_354A', true],
            [:global_means, 'GB_INPUT_B_9WP3_355A', true],
            [:global_merits, 'APP_CARE_SUPERVISION', false],
            [:global_merits, 'APP_DIV_JUDSEP_DISSOLUTION_CP', false],
            [:global_merits, 'APP_INCLUDES_IMMIGRATION_PROCS', false],
            [:global_merits, 'APP_INCLUDES_INQUEST_PROCS', false],
            [:global_merits, 'APP_INCLUDES_RELATED_PROCS', false],
            [:global_merits, 'APP_INCLUDES_SCA_PROCS', false],
            [:global_merits, 'APP_INC_CHILDREN_PROCS', false],
            [:global_merits, 'APP_INC_CHILD_ABDUCTION', false],
            [:global_merits, 'APP_INC_SECURE_ACCOM', false],
            [:global_merits, 'APP_IS_SCA_RELATED', false],
            [:global_merits, 'APP_POTENTIAL_NON_MERITS', false],
            [:global_merits, 'APP_RELATES_EPO_EXTENDEPO_SAO', false],
            [:global_merits, 'APP_SCA_NON_MERITS_TESTED', false],
            [:global_merits, 'CASE_OWNER_COMPLEX_MERITS', false],
            [:global_merits, 'CASE_OWNER_IMMIGRATION', false],
            [:global_merits, 'CASE_OWNER_MENTAL_HEALTH', false],
            [:global_merits, 'CASE_OWNER_SCA', false],
            [:global_merits, 'CASE_OWNER_SCU', false],
            [:global_merits, 'CASE_OWNER_VHCC', false],
            [:global_merits, 'CHILD_MUST_BE_INCLUDED', false],
            [:global_merits, 'CLIENT_CIVIL_PARTNER', false],
            [:global_merits, 'CLIENT_CIVIL_PARTNER_DISSOLVE', false],
            [:global_merits, 'CLIENT_DIVORCED', false],
            [:global_merits, 'CLIENT_JUDICIALLY_SEPARATED', false],
            [:global_merits, 'CLIENT_MARRIED', false],
            [:global_merits, 'CLIENT_SINGLE', false],
            [:global_merits, 'CLIENT_WIDOWED', false],
            [:global_merits, 'CLINICAL_NEGLIGENCE', false],
            [:global_merits, 'COMMUNITY_CARE', false],
            [:global_merits, 'COUNTY_COURT', false],
            [:global_merits, 'COURT_OF_APPEAL', false],
            [:global_merits, 'CRIME', false],
            [:global_merits, 'CROWN_COURT', false],
            [:global_merits, 'CURRENT_CERT_EMERGENCY', false],
            [:global_merits, 'CURRENT_CERT_SUBSTANTIVE', false],
            [:global_merits, 'DEC_AGAINST_INSTRUCTIONS', true],
            [:global_merits, 'EDUCATION', false],
            [:global_merits, 'EMERGENCY_DEC_SIGNED', false],
            [:global_merits, 'EMPLOYMENT_APPEAL_TRIBUNAL', false],
            [:global_merits, 'FIRST_TIER_TRIBUNAL_CARE_STAND', false],
            [:global_merits, 'FIRST_TIER_TRIBUNAL_IMM_ASY', false],
            [:global_merits, 'FIRST_TIER_TRIBUNAL_TAXATION', false],
            [:global_merits, 'HIGH_COURT', false],
            [:global_merits, 'HOUSING', false],
            [:global_merits, 'IMMIGRATION', false],
            [:global_merits, 'IMMIGRATION_CT_OF_APPEAL', false],
            [:global_merits, 'IMMIGRATION_QUESTION_APP', false],
            [:global_merits, 'ISSUE_URGENT_PROCEEDINGS', false],
            [:global_merits, 'LEGAL_HELP_PROVIDED', true],
            [:global_merits, 'LEGALLY_LINKED_SCU', false],
            [:global_merits, 'LEGALLY_LINKED_SIU', false],
            [:global_merits, 'LEGALLY_LINKED_VHCC', false],
            [:global_merits, 'LIMITATION_PERIOD_TO_EXPIRE', false],
            [:global_merits, 'MAGISTRATES_COURT', false],
            [:global_merits, 'MATTER_IS_SWPI', false],
            [:global_merits, 'MENTAL_HEALTH', false],
            [:global_merits, 'MENTAL_HEALTH_REVIEW_TRIBUNAL', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_CORR', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_COUNSEL', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_CT_ORDER', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_EXPERT', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_PLEAD', false],
            [:global_merits, 'NON_MAND_EVIDENCE_AMD_SOLS_RPT', false],
            [:global_merits, 'NON_MAND_EVIDENCE_CORR_ADR', false],
            [:global_merits, 'NON_MAND_EVIDENCE_CORR_SETTLE', false],
            [:global_merits, 'NON_MAND_EVIDENCE_COUNSEL_OP', false],
            [:global_merits, 'NON_MAND_EVIDENCE_CTORDER', false],
            [:global_merits, 'NON_MAND_EVIDENCE_EXPERT_EXIST', false],
            [:global_merits, 'NON_MAND_EVIDENCE_EXPERT_RPT', false],
            [:global_merits, 'NON_MAND_EVIDENCE_ICA_LETTER', false],
            [:global_merits, 'NON_MAND_EVIDENCE_LTTR_ACTION', false],
            [:global_merits, 'NON_MAND_EVIDENCE_OMBUD_RPT', false],
            [:global_merits, 'NON_MAND_EVIDENCE_PLEADINGS', false],
            [:global_merits, 'NON_MAND_EVIDENCE_PRE_ACT_DISC', false],
            [:global_merits, 'NON_MAND_EVIDENCE_SEP_STATE', false],
            [:global_merits, 'NON_MAND_EVIDENCE_WARNING_LTTR', false],
            [:global_merits, 'PREP_OF_STATEMENT_PAPERS', false],
            [:global_merits, 'PROCS_INCLUDE_CHILD', false],
            [:global_merits, 'PROSCRIBED_ORG_APPEAL_COMM', false],
            [:global_merits, 'PUB_AUTH_QUESTION_APPLIES', false],
            [:global_merits, 'PUBLIC_LAW_NON_FAMILY', false],
            [:global_merits, 'REQUESTED_COST_LIMIT_OVER_25K', false],
            [:global_merits, 'RISK_SCA_PR', false],
            [:global_merits, 'ROUTING_COMPLEX_MERITS', false],
            [:global_merits, 'ROUTING_IMMIGRATION', false],
            [:global_merits, 'ROUTING_MENTAL_HEALTH', false],
            [:global_merits, 'ROUTING_SCU', false],
            [:global_merits, 'ROUTING_VHCC', false],
            [:global_merits, 'SCA_APPEAL_INCLUDED', false],
            [:global_merits, 'SCA_AUTO_GRANT', false],
            [:global_merits, 'SMOD_APPLICABLE_TO_MATTER', false],
            [:global_merits, 'SPECIAL_CHILDREN_ACT_APP', false],
            [:global_merits, 'SPECIAL_IMM_APPEAL_COMMISSION', false],
            [:global_merits, 'SUPREME_COURT', false],
            [:global_merits, 'UPPER_TRIBUNAL_IMM_ASY', false],
            [:global_merits, 'UPPER_TRIBUNAL_MENTAL_HEALTH', false],
            [:global_merits, 'UPPER_TRIBUNAL_OTHER', false],
            [:global_merits, 'URGENT_APPLICATION', false],
            [:global_merits, 'URGENT_DIRECTIONS', false],
            [:other_capital, 'OTHCAPITAL_INPUT_B_17WP2_1A', true],
            [:other_capital, 'OTHCAPITAL_INPUT_B_17WP2_2A', true],
            [:other_capital, 'OTHCAPITAL_INPUT_B_17WP2_4A', true],
            [:other_capital, 'OTHCAPITAL_INPUT_B_17WP2_5A', true],
            [:other_savings, 'OTHERSAVING_INPUT_B_10WP2_14A', true],
            [:other_savings, 'OTHERSAVING_INPUT_B_10WP2_15A', true],
            [:other_savings, 'OTHERSAVING_INPUT_B_10WP2_16A', true],
            [:other_savings, 'OTHERSAVING_INPUT_B_10WP2_17A', true],
            [:proceeding_merits, 'ACTION_DAMAGES_AGAINST_POLICE', false],
            [:proceeding_merits, 'APPEAL_IN_SUPREME_COURT', false],
            [:proceeding_merits, 'CLIENT_BRINGING_OR_DEFENDING', false],
            [:proceeding_merits, 'CLIENT_DEFENDANT_3RD_PTY', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_APPELLANT', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_BRING_3RD_PTY', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_BRING_COUNTER', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_CHILD', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_DEF_COUNTER', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_DEFEND_PROCS', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_INTERPLEADER', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_INTERVENOR', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_JOINED_PARTY', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_OTHER', false],
            [:proceeding_merits, 'CLIENT_INV_TYPE_PERSONAL_REP', false],
            [:proceeding_merits, 'FAM_PROSP_BORDERLINE_UNCERT', false],
            [:proceeding_merits, 'FAM_PROSP_GOOD', false],
            [:proceeding_merits, 'FAM_PROSP_VERY_GOOD', false],
            [:proceeding_merits, 'FAM_PROSP_VERY_POOR', false],
            [:proceeding_merits, 'LEVEL_OF_SERV_FHH', false],
            [:proceeding_merits, 'LEVEL_OF_SERV_IH', false],
            [:proceeding_merits, 'LEVEL_OF_SERV_INQUEST', false],
            [:proceeding_merits, 'NON_QUANTIFIABLE_REMEDY', false],
            [:proceeding_merits, 'OVERWHELMING_IMPORTANCE', false],
            [:proceeding_merits, 'PRIVATE_FUNDING_APPLICABLE', false],
            [:proceeding_merits, 'PROC_CA_GATEWAY_APPLIES', false],
            [:proceeding_merits, 'PROC_DV_GATEWAY_APPLIES', false],
            [:proceeding_merits, 'PROC_IMMIGRATION_RELATED', false],
            [:proceeding_merits, 'PROC_IS_SCA_APPEAL', false],
            [:proceeding_merits, 'PROC_LAR_GATEWAY', false],
            [:proceeding_merits, 'PROC_OUTCOME_RECORDED', false],
            [:proceeding_merits, 'PROC_RELATED_PROCEEDING', false],
            [:proceeding_merits, 'PROC_RELATED_SCA_OR_RELATED', false],
            [:proceeding_merits, 'PROC_SCHED1_TRUE', false],
            [:proceeding_merits, 'PROCEEDING_CASE_OWNER_SCU', false],
            [:proceeding_merits, 'PROCEEDING_JUDICIAL_REVIEW', false],
            [:proceeding_merits, 'SCA_APPEAL_FINAL_ORDER', false],
            [:proceeding_merits, 'SIGNIFICANT_WIDER_PUB_INTEREST', false]
          ]
        end
      end
    end
  end
end
