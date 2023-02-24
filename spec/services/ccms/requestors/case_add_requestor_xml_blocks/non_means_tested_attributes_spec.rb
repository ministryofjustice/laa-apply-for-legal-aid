# see sheet for description of attributes
# https://docs.google.com/spreadsheets/d/1hftRRmxBPcyll-akFbiCZgizdsr4uoMZnIaNKod9_lc/edit#gid=1199948510
#
require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe NonMeansTestedCaseAddRequestor, :ccms do
      context "with XML request" do
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }

        let(:legal_aid_application) do
          create(
            :legal_aid_application,
            :with_proceedings,
            :with_under_18_applicant,
            :with_skipped_benefit_check_result,
            :with_non_means_tested_state_machine,
            :with_cfe_empty_result,
            :with_merits_statement_of_case,
            :with_opponent,
            :with_parties_mental_capacity,
            :with_domestic_abuse_summary,
            :with_incident,
            :with_chances_of_success,
            prospect: success_prospect,
            set_lead_proceeding: :da001,
            provider:,
            office:,
          )
        end

        let(:success_prospect) { :likely }

        let(:provider) do
          create(:provider,
                 firm:,
                 selected_office: office,
                 username: 4_953_649)
        end

        let(:firm) { create(:firm, name: "Firm1") }
        let(:office) { create(:office, firm:) }

        let(:expected_tx_id) { "201904011604570390059770666" }
        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:opponent) { legal_aid_application.opponents.first }
        let(:parties_mental_capacity) { legal_aid_application.parties_mental_capacity }
        let(:domestic_abuse_summary) { legal_aid_application.domestic_abuse_summary }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }

        before do
          allow(proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
          allow(Setting).to receive(:means_test_review_phase_one?).and_return(true)
        end

        # uncomment this example to create a file of the payload for manual inspection
        # it 'create example payload file' do
        #   filename = Rails.root.join('tmp/generated_non_means_tested_ccms_payload.xml')
        #   File.open(filename, 'w') { |f| f.puts xml }
        #   expect(File.exist?(filename)).to be true
        # end

        context "with means entity config" do
          it "omits VALUABLE_POSSESSION entity" do
            entity_block = XmlExtractor.call(xml, :valuable_possessions_entity)
            expect(entity_block).not_to be_present, "Expected block for VALUABLE_POSSESSION entity not to be generated, but was \n #{entity_block}"
          end

          it "omits BANKACC entity" do
            entity_block = XmlExtractor.call(xml, :bank_accounts_entity)
            expect(entity_block).not_to be_present, "Expected block for BANKACC entity not to be generated, but was \n #{entity_block}"
          end

          it "omits CARS_AND_MOTOR_VEHICLES entity" do
            entity_block = XmlExtractor.call(xml, :vehicle_entity)
            expect(entity_block).not_to be_present, "Expected block for CARS_AND_MOTOR_VEHICLES entity not to be generated, but was \n #{entity_block}"
          end

          it "omits CLI_NON_HM_WAGE_SLIP entity" do
            entity_block = XmlExtractor.call(xml, :wage_slip_entity)
            expect(entity_block).not_to be_present, "Expected block for CLI_NON_HM_WAGE_SLIP entity not to be generated, but was \n #{entity_block}"
          end

          it "omits EMPLOYMENT_CLIENT entity" do
            entity_block = XmlExtractor.call(xml, :employment_entity)
            expect(entity_block).not_to be_present, "Expected block for EMPLOYMENT_CLIENT entity not to be generated, but was \n #{entity_block}"
          end

          # TODO: what is the expected behaviour for sequences in this context and what is their impact on "injection"
          # xit "assigns the sequence number to the next entity one higher than that for bank accounts" do
          #   bank_account_sequence = XmlExtractor.call(xml, :bank_accounts_sequence).text.to_i

          #   means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
          #   doc = Nokogiri::XML(means_proceeding_entity.to_s)
          #   means_proceeding_sequence = doc.xpath("//SequenceNumber").text.to_i
          #   expect(means_proceeding_sequence).to eq bank_account_sequence + 1
          # end
        end

        context "with DevolvedPowersDate" do
          context "with a Substantive case" do
            it "is omitted" do
              block = XmlExtractor.call(xml, :devolved_powers_date)
              expect(block).not_to be_present, "Expected block for attribute DevolvedPowersDate not to be generated, but was \n #{block}"
            end
          end

          context "with a Delegated Functions case" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "is populated with the delegated functions date" do
              block = XmlExtractor.call(xml, :devolved_powers_date)
              expect(block.children.text).to eq legal_aid_application.used_delegated_functions_on.to_fs(:ccms_date)
            end
          end
        end

        context "with ApplicationAmendmentType" do
          context "with a Substantive case" do
            it "is set to SUB" do
              block = XmlExtractor.call(xml, :application_amendment_type)
              expect(block.children.text).to eq "SUB"
            end
          end

          context "with Delegated Functions used" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "is set to SUBDP" do
              block = XmlExtractor.call(xml, :application_amendment_type)
              expect(block.children.text).to eq "SUBDP"
            end
          end
        end

        it "adds MEANS_REQD attribute with hard coded value false" do
          block = XmlExtractor.call(xml, :global_means, "MEANS_REQD")
          expect(block).to have_boolean_response(false)
        end

        it "adds SA_SCREEN9_4WP1_CHILDUNDER16NA with hard coded value of true" do
          block = XmlExtractor.call(xml, :global_means, "SA_SCREEN9_4WP1_CHILDUNDER16NA")
          expect(block).to have_boolean_response(true)
        end

        it "adds GB_INFER_B_1WP1_1A with hard coded value of true" do
          block = XmlExtractor.call(xml, :global_means, "GB_INFER_B_1WP1_1A")
          expect(block).to have_boolean_response(true)
        end

        it "omits PASSPORTED_NINO" do
          block = XmlExtractor.call(xml, :global_means, "PASSPORTED_NINO")
          expect(block).not_to be_present, "Expected attribute block PASSPORTED_NINO not to be generated, but was \n #{block}"
        end

        it "omits IS_PASSPORTED" do
          block = XmlExtractor.call(xml, :global_means, "IS_PASSPORTED")
          expect(block).not_to be_present, "Expected attribute block IS_PASSPORTED not to be generated, but was \n #{block}"
        end

        context "with CHILD_PARTIES_C" do
          context "with with section8 proceeding" do
            before { allow(proceeding).to receive(:section8?).and_return true }

            it "has response value of true" do
              block = XmlExtractor.call(xml, :proceeding_merits, "CHILD_PARTIES_C")
              expect(block).to have_boolean_response(true)
            end
          end

          context "with domestic abuse proceeding" do
            before { allow(proceeding).to receive(:section8?).and_return false }

            it "has response value of false" do
              block = XmlExtractor.call(xml, :proceeding_merits, "CHILD_PARTIES_C")
              expect(block).to have_boolean_response(false)
            end
          end
        end

        it "omits GB_INFER_T_6WP1_66A" do
          block = XmlExtractor.call(xml, :global_merits, "GB_INFER_T_6WP1_66A")
          expect(block).not_to be_present, "Expected attribute block GB_INFER_T_6WP1_66A not to be generated, but was \n #{block}"
        end

        it "omits CLIENT_ELIGIBILITY" do
          block = XmlExtractor.call(xml, :global_means, "CLIENT_ELIGIBILITY")
          expect(block).not_to be_present, "Expected attribute block CLIENT_ELIGIBILITY not to be generated, but was \n #{block}"
        end

        it "omits PUI_CLIENT_ELIGIBILITY" do
          block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_ELIGIBILITY")
          expect(block).not_to be_present, "Expected attribute block PUI_CLIENT_ELIGIBILITY not to be generated, but was \n #{block}"
        end

        context "with means currency attributes that are required(?!) but not applicable" do
          let(:attributes) { %w[INCOME_CONT CAP_CONT OUT_CAP_CONT PUI_CLIENT_CAP_CONT] }

          it "returns zero", :aggregate_failures do
            attributes.each do |attribute|
              block = XmlExtractor.call(xml, :global_means, attribute)
              expect(block).to have_currency_response "0.00", "Expected attribute block #{attribute} to have currency value of 0.00, but was \n #{block}"
            end
          end
        end

        context "with ProceedingCaseId" do
          let(:proceeding_case_id) { legal_aid_application.proceedings.first.proceeding_case_p_num }

          it "adds ProceedingCaseID to Proceedings block" do
            block = XmlExtractor.call(xml, :proceeding_case_id)
            expect(block.text).to eq(proceeding_case_id)
          end

          it "adds PROCEEDING_ID attribute to merits assessment block" do
            block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_ID")
            expect(block).to have_text_response(proceeding_case_id)
          end

          it "adds PROCEEDING_ID attribute to means assessment block" do
            block = XmlExtractor.call(xml, :proceeding_means, "PROCEEDING_ID")
            expect(block).to have_text_response(proceeding_case_id)
          end
        end

        it "adds APPLICATION_CASE_REF from the submission record means assessment block" do
          block = XmlExtractor.call(xml, :global_means, "APPLICATION_CASE_REF")
          expect(block).to have_text_response(ccms_reference)
        end

        it "adds APPLICATION_CASE_REF from the submission record merits assessment block" do
          block = XmlExtractor.call(xml, :global_merits, "APPLICATION_CASE_REF")
          expect(block).to have_text_response(ccms_reference)
        end

        context "with FAMILY_PROSPECTS_OF_SUCCESS" do
          context "with likely success prospect" do
            let(:success_prospect) { "likely" }

            it "returns the ccms equivalent prospect of success for likely" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Good"
            end
          end

          context "with marginal success prospect" do
            let(:success_prospect) { "marginal" }

            it "returns the ccms equivalent prospect of success for marginal" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Marginal"
            end
          end

          context "with not_known success prospect" do
            let(:success_prospect) { "not_known" }

            it "returns the ccms equivalent prospect of success for not_known" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Uncertain"
            end
          end

          context "with poor success prospect" do
            let(:success_prospect) { "poor" }

            it "returns the ccms equivalent prospect of success for poor" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Poor"
            end
          end

          context "with borderline success prospect" do
            let(:success_prospect) { "borderline" }

            it "returns the ccms equivalent prospect of success for borderline" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Borderline"
            end
          end
        end

        context "with DELEGATED_FUNCTIONS_DATE" do
          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds the DELEGATED_FUNCTIONS_DATE attribute in the means assessment block" do
              block = XmlExtractor.call(xml, :global_means, "DELEGATED_FUNCTIONS_DATE")
              expect(block).to have_date_response(Time.zone.today.strftime("%d-%m-%Y"))
            end

            it "adds the DELEGATED_FUNCTIONS_DATE attribute in the merits assessment section" do
              block = XmlExtractor.call(xml, :global_merits, "DELEGATED_FUNCTIONS_DATE")
              expect(block).to have_date_response(Time.zone.today.strftime("%d-%m-%Y"))
            end
          end

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "omits the DELEGATED_FUNCTIONS_DATE attribute in the means assessment section" do
              block = XmlExtractor.call(xml, :global_means, "DELEGATED_FUNCTIONS_DATE")
              expect(block).not_to be_present
            end

            it "omits the DELEGATED_FUNCTIONS_DATE attribute in the merits assessment section" do
              block = XmlExtractor.call(xml, :global_merits, "DELEGATED_FUNCTIONS_DATE")
              expect(block).not_to be_present
            end
          end
        end

        it "adds EMERGENCY_FC_CRITERIA as hard coded string" do
          block = XmlExtractor.call(xml, :global_merits, "EMERGENCY_FC_CRITERIA")
          expect(block).to have_text_response "."
        end

        it "omits the URGENT_HEARING_DATE attribute in the merits assessment section" do
          block = XmlExtractor.call(xml, :global_merits, "URGENT_HEARING_DATE")
          expect(block).not_to be_present
        end

        it "omits the GB_INPUT_B_2WP2_1A attribute in the means assessment section" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_2WP2_1A")
          expect(block).not_to be_present
        end

        it "omits the GB_INPUT_B_3WP2_1A attribute in the merits assessment section" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_1A")
          expect(block).not_to be_present
        end

        it "adds some boolean attributes with value hard coded to true", :aggregate_failures do
          attributes = [
            [:global_means, "APPLICATION_FROM_APPLY"],
            [:global_means, "GB_INPUT_B_38WP3_2SCREEN"],
            [:global_means, "GB_INPUT_B_38WP3_3SCREEN"],
            [:global_means, "GB_DECL_B_38WP3_13A"],
            [:global_means, "LAR_SCOPE_FLAG"],
            [:global_means, "MEANS_EVIDENCE_PROVIDED"],
            [:global_means, "MEANS_SUBMISSION_PG_DISPLAYED"],
            [:global_merits, "APPLICATION_FROM_APPLY"],
            [:global_merits, "CLIENT_HAS_DV_RISK"],
            [:global_merits, "CLIENT_REQ_SEP_REP"],
            [:global_merits, "DECLARATION_REVOKE_IMP_SUBDP"],
            [:global_merits, "DECLARATION_WILL_BE_SIGNED"],
            [:global_merits, "MERITS_DECLARATION_SCREEN"],
            [:global_merits, "MERITS_EVIDENCE_PROVIDED"],
            [:proceeding_means, "SCOPE_LIMIT_IS_DEFAULT"],
            [:proceeding_merits, "LEAD_PROCEEDING"],
            [:proceeding_merits, "SCOPE_LIMIT_IS_DEFAULT"],
            [:global_merits, "CASE_OWNER_STD_FAMILY_MERITS"],
          ]

          attributes.each do |entity_attribute_pair|
            entity, attribute = entity_attribute_pair
            block = XmlExtractor.call(xml, entity, attribute)
            expect(block).to have_boolean_response true
          end
        end

        context "with applicant details" do
          it "adds applicant's DATE_OF_BIRTH attribute with dob value into means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "DATE_OF_BIRTH")
              expect(block).to have_date_response legal_aid_application.applicant.date_of_birth.strftime("%d-%m-%Y")
            end
          end

          it "adds applicant's FIRST_NAME attribute with value into means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "FIRST_NAME")
              expect(block).to have_text_response legal_aid_application.applicant.first_name
            end
          end

          it "adds applicant's POST_CODE attribute with value into means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "POST_CODE")
              expect(block).to have_text_response legal_aid_application.applicant.address.postcode
            end
          end

          it "adds applicant's SURNAME attribute with value into means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "SURNAME")
              expect(block).to have_text_response legal_aid_application.applicant.last_name
            end
          end

          it "adds applicant's SURNAME_AT_BIRTH attribute with value into means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "SURNAME_AT_BIRTH")
              expect(block).to have_text_response legal_aid_application.applicant.last_name
            end
          end

          it "adds applicant's CLIENT_AGE attribute with value into merits assessment section" do
            block = XmlExtractor.call(xml, :global_merits, "CLIENT_AGE")
            expect(block).to have_number_response legal_aid_application.applicant.age
          end
        end

        it "adds _SYSTEM_PUI_USERID attribute with provider's email address as value" do
          %i[global_means global_merits].each do |entity|
            block = XmlExtractor.call(xml, entity, "_SYSTEM_PUI_USERID")
            expect(block).to have_text_response legal_aid_application.provider.email
          end
        end

        it "adds USER_PROVIDER_FIRM_ID attribute with provider's firm id as the value into means and merits assessment sections" do
          %i[global_means global_merits].each do |entity|
            block = XmlExtractor.call(xml, entity, "USER_PROVIDER_FIRM_ID")
            expect(block).to have_number_response legal_aid_application.provider.firm.ccms_id
          end
        end

        it "omits some attributes from the payload", :aggregate_failures do
          omitted_attributes.each do |entity_attribute_pair|
            entity, attribute = entity_attribute_pair
            block = XmlExtractor.call(xml, entity, attribute)
            expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
          end
        end

        context "with domestic_abuse_summary" do
          context "and bail conditions set" do
            before { domestic_abuse_summary.bail_conditions_set = true }

            it "adds BAIL_CONDITIONS_SET attribute with value of true" do
              block = XmlExtractor.call(xml, :global_merits, "BAIL_CONDITIONS_SET")
              expect(block).to have_boolean_response true
            end
          end

          context "and bail conditions NOT set" do
            before { domestic_abuse_summary.bail_conditions_set = false }

            it "adds BAIL_CONDITIONS_SET attribute with value of false" do
              block = XmlExtractor.call(xml, :global_merits, "BAIL_CONDITIONS_SET")
              expect(block).to have_boolean_response false
            end
          end

          context "and police notified" do
            before { domestic_abuse_summary.update(police_notified: true) }

            it "adds POLICE_NOTIFIED attribute with true value" do
              block = XmlExtractor.call(xml, :global_merits, "POLICE_NOTIFIED")
              expect(block).to have_boolean_response true
            end
          end

          context "and police NOT notified" do
            before { domestic_abuse_summary.update(police_notified: false) }

            it "adds POLICE_NOTIFIED attribute with false value" do
              block = XmlExtractor.call(xml, :global_merits, "POLICE_NOTIFIED")
              expect(block).to have_boolean_response false
            end
          end

          context "and a warning letter has been sent" do
            before { domestic_abuse_summary.update(warning_letter_sent: true) }

            it "adds WARNING_LETTER_SENT attribute with true value" do
              block = XmlExtractor.call(xml, :global_merits, "WARNING_LETTER_SENT")
              expect(block).to have_boolean_response true
            end

            it "omits INJ_REASON_NO_WARNING_LETTER attribute" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_REASON_NO_WARNING_LETTER")
              expect(block).not_to be_present, "Expected block for attribute INJ_REASON_NO_WARNING_LETTER not to be generated, but was in global_merits"
            end
          end

          context "and a warning letter has not been sent" do
            before { domestic_abuse_summary.update(warning_letter_sent: false) }

            it "adds WARNING_LETTER_SENT attribute with false value" do
              block = XmlExtractor.call(xml, :global_merits, "WARNING_LETTER_SENT")
              expect(block).to have_boolean_response false
            end

            it "adds INJ_REASON_NO_WARNING_LETTER attribute with expected text" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_REASON_NO_WARNING_LETTER")
              expect(block).to have_text_response "."
            end
          end
        end

        context "when domestic abuse summary not applicable to proceeding" do
          before do
            legal_aid_application.domestic_abuse_summary.delete
            legal_aid_application.reload
          end

          it "omits the BAIL_CONDITIONS_SET block" do
            block = XmlExtractor.call(xml, :global_merits, "BAIL_CONDITIONS_SET")
            expect(block).not_to be_present
          end

          it "omits the POLICE_NOTIFIED block" do
            block = XmlExtractor.call(xml, :global_merits, "POLICE_NOTIFIED")
            expect(block).not_to be_present
          end
        end

        context "when parties mental capacity recorded" do
          context "and opponent has capacity" do
            before { parties_mental_capacity.understands_terms_of_court_order = true }

            it "adds INJ_RESPONDENT_CAPACITY attribute with true value" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_RESPONDENT_CAPACITY")
              expect(block).to have_boolean_response true
            end
          end

          context "and opponent does not have capacity" do
            before { parties_mental_capacity.understands_terms_of_court_order = false }

            it "adds INJ_RESPONDENT_CAPACITY attribute with false value" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_RESPONDENT_CAPACITY")
              expect(block).to have_boolean_response false
            end
          end
        end

        context "when parties mental capacity not applicable to proceeding" do
          before do
            legal_aid_application.parties_mental_capacity.delete
            legal_aid_application.reload
          end

          it "omits the INJ_RESPONDENT_CAPACITY block" do
            block = XmlExtractor.call(xml, :global_merits, "INJ_RESPONDENT_CAPACITY")
            expect(block).not_to be_present
          end
        end

        it "omits BEN_DOB" do
          block = XmlExtractor.call(xml, :global_means, "BEN_DOB")
          expect(block).not_to be_present, "Expected attribute block BEN_DOB not to be generated, but was \n #{block}"
        end

        it "omits BEN_NI_NO" do
          block = XmlExtractor.call(xml, :global_means, "BEN_NI_NO")
          expect(block).not_to be_present, "Expected attribute block BEN_NI_NO not to be generated, but was \n #{block}"
        end

        it "omits BEN_SURNAME" do
          block = XmlExtractor.call(xml, :global_means, "BEN_SURNAME")
          expect(block).not_to be_present, "Expected attribute block BEN_SURNAME not to be generated, but was \n #{block}"
        end

        it "LAR_INFER_B_1WP1_36A is present with value of false" do
          block = XmlExtractor.call(xml, :global_means, "LAR_INFER_B_1WP1_36A")
          expect(block).to have_boolean_response false
        end

        context "with DELEG_FUNCTIONS_DATE_MERITS" do
          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: dummy_date, used_delegated_functions_reported_on: dummy_date)
              end
            end

            let(:dummy_date) { Time.zone.today }

            it "adds DELEG_FUNCTIONS_DATE_MERITS attribute with date string" do
              block = XmlExtractor.call(xml, :global_merits, "DELEG_FUNCTIONS_DATE_MERITS")
              expect(block).to have_date_response(dummy_date.strftime("%d-%m-%Y"))
            end
          end

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "omits DELEG_FUNCTIONS_DATE_MERITS attribute block" do
              block = XmlExtractor.call(xml, :global_merits, "DELEG_FUNCTIONS_DATE_MERITS")
              expect(block).not_to be_present, "Expected block for attribute DELEG_FUNCTIONS_DATE_MERITS not to be generated, but was \n #{block}"
            end
          end
        end

        context "with APP_GRANTED_USING_DP" do
          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds APP_GRANTED_USING_DP attribute with true value" do
              block = XmlExtractor.call(xml, :global_merits, "APP_GRANTED_USING_DP")
              expect(block).to have_boolean_response(true)
            end
          end

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "adds APP_GRANTED_USING_DP attribute with false value" do
              block = XmlExtractor.call(xml, :global_merits, "APP_GRANTED_USING_DP")
              expect(block).to have_boolean_response(false)
            end
          end
        end

        context "with APP_AMEND_TYPE" do
          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds APP_AMEND_TYPE attribute with SUBDP value to means and mertis assessment sections" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APP_AMEND_TYPE")
                expect(block).to have_text_response "SUBDP"
              end
            end
          end

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "adds APP_AMEND_TYPE attribute with SUB value to means and mertis assessment sections" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APP_AMEND_TYPE")
                expect(block).to have_text_response "SUB"
              end
            end
          end
        end

        context "with EMERGENCY_FURTHER_INFORMATION" do
          let(:block) { XmlExtractor.call(xml, :global_merits, "EMERGENCY_FURTHER_INFORMATION") }

          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds EMERGENCY_FURTHER_INFORMATION attribute with expected value" do
              expect(block).to have_text_response "."
            end
          end

          context "with delegated function not used" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "omits EMERGENCY_FURTHER_INFORMATION attribute" do
              expect(block).not_to be_present
            end
          end
        end

        it "omits GB_INPUT_B_15WP2_8A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_15WP2_8A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_14WP2_8A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_14WP2_8A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_16WP2_7A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_16WP2_7A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_12WP2_2A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_12WP2_2A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_6WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_6WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_5WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_9WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_4WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_4WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_5WP1_18A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_18A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_7WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_7WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_8WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_8WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_D_18WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_D_18WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_10WP2_1A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_10WP2_1A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_13WP2_7A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_13WP2_7A")
          expect(block).not_to be_present
        end

        it "omits GB_INPUT_B_11WP2_3A attribute" do
          block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_11WP2_3A")
          expect(block).not_to be_present
        end

        it "adds GB_DECL_B_38WP3_11A attribute with value of false" do
          block = XmlExtractor.call(xml, :global_means, "GB_DECL_B_38WP3_11A")
          expect(block).to have_boolean_response false
        end

        context "with attributes with specific hard coded values" do
          it "adds DEVOLVED_POWERS_CONTRACT_FLAG attribute with expected hard coded" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "DEVOLVED_POWERS_CONTRACT_FLAG")
              expect(block).to have_text_response "Yes - Excluding JR Proceedings"
            end
          end

          it "attributes with values hard coded to boolean false", :aggregate_failures do
            false_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response(false), "Expected attribute #{attribute} to have hard coded boolean value of false"
            end
          end

          it "adds CASES_FEES_DISTRIBUTED attribute with hard coded value of 1" do
            block = XmlExtractor.call(xml, :global_merits, "CASES_FEES_DISTRIBUTED")
            expect(block).to have_number_response(1)
          end

          it "adds LEVEL_OF_SERVICE attribute with value from substantive level of service" do
            %i[proceeding_means proceeding_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "LEVEL_OF_SERVICE")
              expect(block).to have_text_response proceeding.substantive_level_of_service.to_s
            end
          end

          it "adds PROCEEDING_LEVEL_OF_SERVICE attribute with value from substantive level of service name" do
            block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_LEVEL_OF_SERVICE")
            expect(block).to have_text_response proceeding.substantive_level_of_service_name
          end

          context "with CLIENT_INVOLVEMENT_TYPE" do
            context "when proceeding has a client involvement type of Applicant, A" do
              before do
                legal_aid_application.proceedings.each do |proceeding|
                  proceeding.update!(client_involvement_type_ccms_code: "A")
                end
              end

              it "adds CLIENT_INVOLVEMENT_TYPE attributes with value of A in means proceedings and merits proceedings" do
                %i[proceeding_means proceeding_merits].each do |entity|
                  block = XmlExtractor.call(xml, entity, "CLIENT_INVOLVEMENT_TYPE")
                  expect(block).to have_text_response "A"
                end
              end
            end

            context "when proceeding has a client involvement type of Defendant, D" do
              before do
                legal_aid_application.proceedings.each do |proceeding|
                  proceeding.update!(client_involvement_type_ccms_code: "D")
                end
              end

              it "adds CLIENT_INVOLVEMENT_TYPE attributes with value of D in means proceedings and merits proceedings" do
                %i[proceeding_means proceeding_merits].each do |entity|
                  block = XmlExtractor.call(xml, entity, "CLIENT_INVOLVEMENT_TYPE")
                  expect(block).to have_text_response "D"
                end
              end
            end
          end

          it "adds COST_LIMIT_CHANGED_FLAG attribute with hard coded text value of false in means and merits sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "COST_LIMIT_CHANGED_FLAG")
              expect(block).to have_text_response "false"
            end
          end

          it "adds NEW_APPL_OR_AMENDMENT attribute with hard coded text value of APPLICATION in means and merits sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "NEW_APPL_OR_AMENDMENT")
              expect(block).to have_text_response "APPLICATION"
            end
          end

          it "adds USER_TYPE attribute with hard coded text value of EXTERNAL in means and merits sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "USER_TYPE")
              expect(block).to have_text_response "EXTERNAL"
            end
          end

          it "adds COUNTRY attribute with hard coded text value of GBR in means and merits sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "COUNTRY")
              expect(block).to have_text_response "GBR"
            end
          end

          it "MARITIAL_STATUS should be hard coded to UNKNOWN in means assessment section" do
            block = XmlExtractor.call(xml, :global_means, "MARITIAL_STATUS")
            expect(block).to have_text_response "UNKNOWN"
          end

          context "with REQUESTED_SCOPE" do
            context "when delegated functions are used on the proceeding" do
              before do
                proceeding = legal_aid_application.proceedings.first
                proceeding.scope_limitations.destroy_all

                proceeding.update!(used_delegated_functions: true,
                                   used_delegated_functions_on: 1.day.ago,
                                   used_delegated_functions_reported_on: 1.day.ago)
              end

              it "adds REQUESTED_SCOPE with value of MULTIPLE in proceeding means and merits section" do
                %i[proceeding_means proceeding_merits].each do |entity|
                  block = XmlExtractor.call(xml, entity, "REQUESTED_SCOPE")
                  expect(block).to have_text_response "MULTIPLE"
                end
              end
            end

            context "when there is one scope limitation and no delegated functions on the proceeding" do
              before do
                proceeding = legal_aid_application.proceedings.first
                proceeding.scope_limitations.destroy_all
                create(:scope_limitation, :substantive, proceeding:)
              end

              it "adds REQUESTED_SCOPE attribute with value of the substantive scope limitation code" do
                %i[proceeding_means proceeding_merits].each do |entity|
                  block = XmlExtractor.call(xml, entity, "REQUESTED_SCOPE")
                  expect(block).to have_text_response legal_aid_application.proceedings.first.substantive_scope_limitations.first.code
                end
              end
            end

            context "when there are multiple scope limitations and no delegated functions on the proceeding" do
              before do
                proceeding = legal_aid_application.proceedings.first
                proceeding.scope_limitations.destroy_all
                create_list(:scope_limitation, 2, :substantive, proceeding:)
              end

              it "adds REQUESTED_SCOPE with value of MULTIPLE in proceeding means and merits section" do
                %i[proceeding_means proceeding_merits].each do |entity|
                  block = XmlExtractor.call(xml, entity, "REQUESTED_SCOPE")
                  expect(block).to have_text_response "MULTIPLE"
                end
              end
            end
          end

          it "adds NEW_OR_EXISTING attribute with NEW in proceedings means and merits sections" do
            %i[proceeding_means proceeding_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "NEW_OR_EXISTING")
              expect(block).to have_text_response "NEW"
            end
          end

          it "adds POA_OR_BILL_FLAG attribute with N/A in global means section" do
            block = XmlExtractor.call(xml, :global_means, "POA_OR_BILL_FLAG")
            expect(block).to have_text_response "N/A"
          end

          it "adds MERITS_ROUTING attribute with SFM in global merits section" do
            block = XmlExtractor.call(xml, :global_merits, "MERITS_ROUTING")
            expect(block).to have_text_response "SFM"
          end

          it "returns a hard coded response with value of '.'" do
            attributes = [
              [:proceeding_merits, "INJ_RECENT_INCIDENT_DETAIL"],
              [:global_merits, "INJ_REASON_POLICE_NOT_NOTIFIED"],
              [:global_merits, "REASON_APPLYING_FHH_LR"],
              [:global_merits, "REASON_NO_ATTEMPT_TO_SETTLE"],
              [:global_merits, "REASON_SEPARATE_REP_REQ"],
              [:global_merits, "MAIN_PURPOSE_OF_APPLICATION"],
              [:global_means, "LAR_INPUT_T_1WP2_8A"],
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response "."
            end
          end
        end

        context "with legal framework attributes" do
          it "adds REQ_COST_LIMITATION attribute with value from application to means and merits assessment section" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "REQ_COST_LIMITATION")
              expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
            end
          end

          it "adds APP_IS_FAMILY attribute with value from application to merits assessment section" do
            block = XmlExtractor.call(xml, :global_merits, "APP_IS_FAMILY")
            expect(block).to have_boolean_response(proceeding.category_of_law == "Family")
          end

          it "adds CAT_OF_LAW_DESCRIPTION attribute with value from application to merits assessment section" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_DESCRIPTION")
            expect(block).to have_text_response proceeding.category_of_law
          end

          it "adds CAT_OF_LAW_HIGH_LEVEL attribute with value from application to merits assessment section" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_HIGH_LEVEL")
            expect(block).to have_text_response proceeding.category_of_law
          end

          it "adds CAT_OF_LAW_MEANING attribute with value from application to merits assessment section" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_MEANING")
            expect(block).to have_text_response proceeding.meaning
          end

          it "adds CATEGORY_OF_LAW attribute with value from application to means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "CATEGORY_OF_LAW")
              expect(block).to have_text_response proceeding.category_law_code
            end
          end

          it "adds DEFAULT_COST_LIMITATION_MERITS attribute with value from application to merits assessment sections" do
            block = XmlExtractor.call(xml, :global_merits, "DEFAULT_COST_LIMITATION_MERITS")
            expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
          end

          it "adds DEFAULT_COST_LIMITATION attribute with value from application to means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "DEFAULT_COST_LIMITATION")
              expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
            end
          end

          it "adds MATTER_TYPE attribute with value from application to means and merits assessment sections" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "MATTER_TYPE")
              expect(block).to have_text_response proceeding.ccms_matter_code
            end
          end

          it "adds PROCEEDING_NAME attribute with value from application to means and merits assessment sections" do
            block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_NAME")
            expect(block).to have_text_response proceeding.ccms_code
          end
        end

        context "with SUBSTANTIVE_APP" do
          let(:block) { XmlExtractor.call(xml, :global_merits, "SUBSTANTIVE_APP") }

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "adds SUBSTANTIVE_APP attribute with value of true to merits assessment section" do
              expect(block).to have_boolean_response true
            end
          end

          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds SUBSTANTIVE_APP attribute with value of false to merits assessment section" do
              expect(block).to have_boolean_response false
            end
          end
        end

        context "with PROCEEDING_APPLICATION_TYPE" do
          let(:block) { XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_APPLICATION_TYPE") }

          context "when not using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: false)
              end
            end

            it "adds PROCEEDING_APPLICATION_TYPE attribute with value of Substantive to proceeding merits section" do
              expect(block).to have_text_response "Substantive"
            end
          end

          context "when using delegated functions" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "adds PROCEEDING_APPLICATION_TYPE attribute with value of Both to proceeding merits section" do
              expect(block).to have_text_response "Both"
            end
          end
        end

        context "with a single opponent" do
          context "with means OPPONENT_OTHER_PARTIES entity" do
            let(:entity) { :opponent_means }

            it "generates OTHER_PARTY_ID" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_ID")
              expect(block).to have_text_response "OPPONENT_88000001"
            end

            it "adds OTHER_PARTY_NAME with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME")
              expect(block).to have_text_response opponent.full_name
            end

            it "hard-codes OTHER_PARTY_TYPE" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_TYPE")
              expect(block).to have_text_response "PERSON"
            end

            it "hard-codes RELATIONSHIP_TO_CASE" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response "OPP"
            end

            it "hard-codes RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response "UNKNOWN"
            end
          end

          context "with merits OPPONENT_OTHER_PARTIES entity" do
            let(:entity) { :opponent_merits }

            it "hard-codes OPP_RELATIONSHIP_TO_CASE" do
              block = XmlExtractor.call(xml, entity, "OPP_RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response "Opponent"
            end

            it "hard-codes OPP_RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "OPP_RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response "Unknown"
            end

            it "generates OTHER_PARTY_ID" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_ID")
              expect(block).to have_text_response "OPPONENT_88000001"
            end

            it "adds OTHER_PARTY_NAME with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME")
              expect(block).to have_text_response opponent.full_name
            end

            it "adds OTHER_PARTY_NAME_MERITS with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME_MERITS")
              expect(block).to have_text_response opponent.full_name
            end

            it "hard-codes OTHER_PARTY_TYPE" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_TYPE")
              expect(block).to have_text_response "PERSON"
            end

            it "hard-codes OTHER_PARTY_PERSON" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_PERSON")
              expect(block).to have_boolean_response true
            end

            it "adds RELATIONSHIP_CASE_OPPONENT with derived value" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_CASE_OPPONENT")
              expect(block).to have_boolean_response true
            end

            it "adds RELATIONSHIP_TO_CASE with derived value" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response "OPP"
            end

            it "hard-codes RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response "UNKNOWN"
            end
          end
        end

        context "with multiple opponents" do
          let(:opponent_one) { create(:opponent, first_name: "Joffrey", last_name: "Test-Opponent") }
          let(:opponent_two) { create(:opponent, first_name: "Sansa", last_name: "Opponent-Test") }

          before { legal_aid_application.update!(opponents: [opponent_one, opponent_two]) }

          context "with means OPPONENT_OTHER_PARTIES entity" do
            let(:entity) { :opponent_means }

            it "generates OTHER_PARTY_ID" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_ID")
              expect(block).to have_text_response %w[OPPONENT_88000001 OPPONENT_88000002]
            end

            it "adds OTHER_PARTY_NAME with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME")
              expect(block).to have_text_response [opponent_one.full_name, opponent_two.full_name]
            end

            it "hard-codes OTHER_PARTY_TYPE" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_TYPE")
              expect(block).to have_text_response %w[PERSON PERSON]
            end

            it "hard-codes RELATIONSHIP_TO_CASE" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response %w[OPP OPP]
            end

            it "hard-codes RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response %w[UNKNOWN UNKNOWN]
            end
          end

          context "with merits OPPONENT_OTHER_PARTIES entity" do
            let(:entity) { :opponent_merits }

            it "hard-codes OPP_RELATIONSHIP_TO_CASE" do
              block = XmlExtractor.call(xml, entity, "OPP_RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response %w[Opponent Opponent]
            end

            it "hard-codes OPP_RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "OPP_RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response %w[Unknown Unknown]
            end

            it "generates OTHER_PARTY_ID" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_ID")
              expect(block).to have_text_response %w[OPPONENT_88000001 OPPONENT_88000002]
            end

            it "adds OTHER_PARTY_NAME with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME")
              expect(block).to have_text_response [opponent_one.full_name, opponent_two.full_name]
            end

            it "adds OTHER_PARTY_NAME_MERITS with value of full name of other party" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_NAME_MERITS")
              expect(block).to have_text_response [opponent_one.full_name, opponent_two.full_name]
            end

            it "hard-codes OTHER_PARTY_TYPE" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_TYPE")
              expect(block).to have_text_response %w[PERSON PERSON]
            end

            it "hard-codes OTHER_PARTY_PERSON" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_PERSON")
              expect(block).to have_boolean_response [true, true]
            end

            it "adds RELATIONSHIP_CASE_OPPONENT with derived value" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_CASE_OPPONENT")
              expect(block).to have_boolean_response [true, true]
            end

            it "adds RELATIONSHIP_TO_CASE with derived value" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CASE")
              expect(block).to have_text_response %w[OPP OPP]
            end

            it "hard-codes RELATIONSHIP_TO_CLIENT" do
              block = XmlExtractor.call(xml, entity, "RELATIONSHIP_TO_CLIENT")
              expect(block).to have_text_response %w[UNKNOWN UNKNOWN]
            end
          end
        end

        context "with APPLY_CASE_MEANS_REVIEW" do
          before { allow(ManualReviewDeterminer).to receive(:new).and_return(determiner) }

          let(:determiner) { instance_double ManualReviewDeterminer }

          context "when Manual review required" do
            before { allow(determiner).to receive(:manual_review_required?).and_return(true) }

            it "adds APPLY_CASE_MEANS_REVIEW attribute with value of false" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APPLY_CASE_MEANS_REVIEW")
                expect(block).to have_boolean_response false
              end
            end
          end

          context "when Manual review not required" do
            before { allow(determiner).to receive(:manual_review_required?).and_return(false) }

            it "adds APPLY_CASE_MEANS_REVIEW attribute with value of true" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APPLY_CASE_MEANS_REVIEW")
                expect(block).to have_boolean_response true
              end
            end
          end
        end
      end

      def omitted_attributes
        [
          [:family_statement],
          [:main_dwelling],
          [:main_dwelling, "MAINTHIRD_INPUT_T_3WP2_12A"],
          [:main_dwelling, "MAINTHIRD_INPUT_T_3WP2_13A"],
          [:main_dwelling, "MAINTHIRD_INPUT_N_3WP2_11A"],
          [:family_statement, "FAMILY_STMT_DETAIL"],
          [:family_statement, "FAMILY_STATEMENT_INSTANCE"],
          [:family_statement, "GB_DECL_T_38WP3_32A"],
          [:change_in_circumstances],
          [:change_in_circumstances, "CHANGE_CIRC_INPUT_T_33WP3_6A"],
          [:global_means, "BEN_AWARD_DATE"],
          [:global_means, "CLIENT_NASS"],
          [:global_means, "CLIENT_PRISONER"],
          [:global_means, "CLIENT_VULNERABLE"],
          [:global_means, "CONFIRMED_NOT_PASSPORTED"],
          [:global_means, "DATE_ASSESSMENT_STARTED"],
          [:global_means, "EMP_INPUT_B_3WP3_60A"],
          [:global_means, "EMP_INPUT_B_3WP3_62A"],
          [:global_means, "EMP_INPUT_B_3WP3_63A"],
          [:global_means, "EMP_INFER_C_15WP3_12A"],
          [:global_means, "EMP_INFER_C_15WP3_13A"],
          [:global_means, "EMP_INPUT_D_3WP3_5A"],
          [:global_means, "EMP_INPUT_N_3WP3_6A"],
          [:global_means, "EMP_INPUT_T_3WP3_2A"],
          [:global_means, "EMP_INPUT_T_3WP3_4A"],
          [:global_means, "EMP_INPUT_T_3WP3_23A"],
          [:global_means, "EMP_INPUT_T_3WP3_28A"],
          [:global_means, "EMP_INPUT_T_3WP3_29A"],
          [:global_means, "GB_DECL_T_38WP3_1A"],
          [:global_means, "GB_DECL_T_38WP3_2A"],
          [:global_means, "GB_DECL_T_38WP3_3A"],
          [:global_means, "GB_DECL_T_38WP3_4A"],
          [:global_means, "GB_DECL_T_38WP3_5A"],
          [:global_means, "GB_DECL_T_38WP3_6A"],
          [:global_means, "GB_DECL_T_38WP3_7A"],
          [:global_means, "GB_DECL_T_38WP3_8A"],
          [:global_means, "GB_DECL_T_38WP3_9A"],
          [:global_means, "GB_DECL_T_38WP3_10A"],
          [:global_means, "GB_DECL_T_38WP3_11A"],
          [:global_means, "GB_DECL_T_38WP3_12A"],
          [:global_means, "GB_DECL_T_38WP3_13A"],
          [:global_means, "GB_DECL_T_38WP3_14A"],
          [:global_means, "GB_DECL_T_38WP3_15A"],
          [:global_means, "GB_DECL_T_38WP3_16A"],
          [:global_means, "GB_DECL_T_38WP3_17A"],
          [:global_means, "GB_DECL_T_38WP3_18A"],
          [:global_means, "GB_DECL_T_38WP3_19A"],
          [:global_means, "GB_DECL_T_38WP3_20A"],
          [:global_means, "GB_DECL_T_38WP3_21A"],
          [:global_means, "GB_DECL_T_38WP3_33A"],
          [:global_means, "GB_DECL_T_38WP3_34A"],
          [:global_means, "GB_DECL_T_38WP3_35A"],
          [:global_means, "GB_DECL_T_38WP3_36A"],
          [:global_means, "GB_DECL_T_38WP3_37A"],
          [:global_means, "GB_DECL_T_38WP3_38A"],
          [:global_means, "GB_DECL_T_38WP3_39A"],
          [:global_means, "GB_DECL_T_38WP3_40A"],
          [:global_means, "GB_DECL_T_38WP3_41A"],
          [:global_means, "GB_DECL_T_38WP3_42A"],
          [:global_means, "GB_DECL_T_38WP3_43A"],
          [:global_means, "GB_DECL_T_38WP3_44A"],
          [:global_means, "GB_DECL_T_38WP3_45A"],
          [:global_means, "GB_DECL_T_38WP3_46A"],
          [:global_means, "GB_DECL_T_38WP3_116A"],
          [:global_means, "GB_INFER_B_1WP3_419A"],
          [:global_means, "GB_INFER_B_26WP3_214A"],
          [:global_means, "GB_INFER_B_3WP2_403A"],
          [:global_means, "GB_INFER_B_3WP2_404A"],
          [:global_means, "GB_INFER_C_31WP3_13A"],
          [:global_means, "GB_INFER_C_28WP4_10A"],
          [:global_means, "GB_INFER_C_28WP4_20A"],
          [:global_means, "GB_INPUT_B_1WP2_36A"],
          [:global_means, "GB_INPUT_B_1WP3_165A"],
          [:global_means, "GB_INPUT_B_1WP3_175A"],
          [:global_means, "GB_INPUT_B_1WP3_400A"],
          [:global_means, "GB_INPUT_B_1WP3_401A"],
          [:global_means, "GB_INPUT_B_12WP3_1A"],
          [:global_means, "GB_INPUT_B_12WP3_3A"],
          [:global_means, "GB_INPUT_B_13WP3_1A"],
          [:global_means, "GB_INPUT_B_13WP3_14A"],
          [:global_means, "GB_INPUT_B_13WP3_15A"],
          [:global_means, "GB_INPUT_B_13WP3_2A"],
          [:global_means, "GB_INPUT_B_13WP3_36A"],
          [:global_means, "GB_INPUT_B_13WP3_37A"],
          [:global_means, "GB_INPUT_B_13WP3_49A"],
          [:global_means, "GB_INPUT_B_13WP3_5A"],
          [:global_means, "GB_INPUT_B_13WP3_6A"],
          [:global_means, "GB_INPUT_B_13WP3_7A"],
          [:global_means, "GB_INPUT_B_14WP2_7A"],
          [:global_means, "GB_INPUT_B_14WP3_1A"],
          [:global_means, "GB_INPUT_B_2WP3_214A"],
          [:global_means, "GB_INPUT_B_2WP4_2A"],
          [:global_means, "GB_INPUT_B_21WP3_389A"],
          [:global_means, "GB_INPUT_B_3WP2_10A"],
          [:global_means, "GB_INPUT_B_3WP2_20A"],
          [:global_means, "GB_INPUT_B_3WP2_25A"],
          [:global_means, "GB_INPUT_B_3WP2_27A"],
          [:global_means, "GB_INPUT_B_3WP2_8A"],
          [:global_means, "GB_INPUT_B_3WP3_393A"],
          [:global_means, "GB_INPUT_B_34WP3_32A"],
          [:global_means, "GB_INPUT_B_39WP3_52A"],
          [:global_means, "GB_INPUT_B_39WP3_52A"],
          [:global_means, "GB_INPUT_B_39WP3_64A"],
          [:global_means, "GB_INPUT_B_40WP3_64A"],
          [:global_means, "GB_INPUT_B_41WP3_20A"],
          [:global_means, "GB_INPUT_B_41WP3_23A"],
          [:global_means, "GB_INPUT_B_41WP3_32A"],
          [:global_means, "GB_INPUT_B_6WP3_232A"],
          [:global_means, "GB_INPUT_B_6WP3_233A"],
          [:global_means, "GB_INPUT_B_6WP3_234A"],
          [:global_means, "GB_INPUT_B_6WP3_235A"],
          [:global_means, "GB_INPUT_B_6WP3_236A"],
          [:global_means, "GB_INPUT_B_6WP3_237A"],
          [:global_means, "GB_INPUT_B_6WP3_238A"],
          [:global_means, "GB_INPUT_B_6WP3_239A"],
          [:global_means, "GB_INPUT_B_6WP3_240A"],
          [:global_means, "GB_INPUT_B_6WP3_241A"],
          [:global_means, "GB_INPUT_B_6WP3_254A"],
          [:global_means, "GB_INPUT_B_8WP3_308A"],
          [:global_means, "GB_INPUT_B_8WP3_310A"],
          [:global_means, "GB_INPUT_B_9WP3_349A"],
          [:global_means, "GB_INPUT_B_9WP3_350A"],
          [:global_means, "GB_INPUT_B_9WP3_351A"],
          [:global_means, "GB_INPUT_B_9WP3_352A"],
          [:global_means, "GB_INPUT_B_9WP3_353A"],
          [:global_means, "GB_INPUT_B_9WP3_356A"],
          [:global_means, "GB_INPUT_C_13WP3_3A"],
          [:global_means, "GB_INPUT_C_13WP3_4A"],
          [:global_means, "GB_INPUT_C_13WP3_12A"],
          [:global_means, "GB_INPUT_C_3WP2_5A"],
          [:global_means, "GB_INPUT_C_3WP2_7A"],
          [:global_means, "GB_INPUT_C_6WP3_228A"],
          [:global_means, "GB_INPUT_N_3WP2_14A"],
          [:global_means, "GB_INPUT_N_3WP2_4A"],
          [:global_means, "GB_INPUT_N_6WP3_231A"],
          [:global_means, "GB_INPUT_T_2WP3_50A"],
          [:global_means, "GB_INPUT_T_3WP2_3A"],
          [:global_means, "GB_INPUT_T_6WP3_229A"],
          [:global_means, "GB_PROC_B_1WP4_99A"],
          [:global_means, "GB_RFLAG_B_2WP3_01A"],
          [:global_means, "LAR_RFLAG_B_37WP2_41A"],
          [:global_means, "MEANS_OPA_RELEASE"],
          [:global_means, "MEANS_REPORT_BACKLOG_TAG"],
          [:global_means, "MEANS_ROUTING"],
          [:global_means, "MEANS_TASK_AUTO_GEN"],
          [:global_means, "OUT_EMP_INFER_C_15WP3_11A"],
          [:global_means, "OUT_GB_INFER_C_14WP4_19A"],
          [:global_means, "OUT_GB_INFER_C_14WP4_3A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_133A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_134A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_135A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_140A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_141A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_142A"],
          [:global_means, "OUT_GB_INFER_C_15WP3_143A"],
          [:global_means, "OUT_GB_INFER_C_16WP4_3A"],
          [:global_means, "OUT_GB_INFER_C_16WP4_4A"],
          [:global_means, "OUT_GB_INFER_C_17WP4_1A"],
          [:global_means, "OUT_GB_INFER_C_18WP3_219A"],
          [:global_means, "OUT_GB_INFER_C_18WP3_226A"],
          [:global_means, "OUT_GB_INFER_C_18WP3_227A"],
          [:global_means, "OUT_GB_INFER_C_18WP3_407A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_101A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_102A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_104A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_105A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_106A"],
          [:global_means, "OUT_GB_INFER_C_19WP2_109A"],
          [:global_means, "OUT_GB_INFER_C_19WP3_144A"],
          [:global_means, "OUT_GB_INFER_C_20WP2_101A"],
          [:global_means, "OUT_GB_INFER_C_20WP2_104A"],
          [:global_means, "OUT_GB_INFER_C_21WP2_101A"],
          [:global_means, "OUT_GB_INFER_C_21WP2_104A"],
          [:global_means, "OUT_GB_INFER_C_21WP3_162A"],
          [:global_means, "OUT_GB_INFER_C_21WP4_1A"],
          [:global_means, "OUT_GB_INFER_C_22WP3_150A"],
          [:global_means, "OUT_GB_INFER_C_22WP3_155A"],
          [:global_means, "OUT_GB_INFER_C_23WP3_158A"],
          [:global_means, "OUT_GB_INFER_C_23WP3_159A"],
          [:global_means, "OUT_GB_INFER_C_23WP3_160A"],
          [:global_means, "OUT_GB_INFER_C_23WP3_161A"],
          [:global_means, "OUT_GB_INFER_C_24WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_24WP2_102A"],
          [:global_means, "OUT_GB_INFER_C_24WP4_1A"],
          [:global_means, "OUT_GB_INFER_C_25WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_25WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_25WP2_108A"],
          [:global_means, "OUT_GB_INFER_C_25WP3_167A"],
          [:global_means, "OUT_GB_INFER_C_26WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_26WP2_105A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_182A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_186A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_194A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_197A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_217A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_218A"],
          [:global_means, "OUT_GB_INFER_C_26WP3_219A"],
          [:global_means, "OUT_GB_INFER_C_27WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_27WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_27WP3_216A"],
          [:global_means, "OUT_GB_INFER_C_27WP3_218A"],
          [:global_means, "OUT_GB_INFER_C_28WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_28WP4_2A"],
          [:global_means, "OUT_GB_INFER_C_28WP4_3A"],
          [:global_means, "OUT_GB_INFER_C_29WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_29WP4_1A"],
          [:global_means, "OUT_GB_INFER_C_30WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_30WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_30WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_30WP3_2A"],
          [:global_means, "OUT_GB_INFER_C_30WP4_1A"],
          [:global_means, "OUT_GB_INFER_C_30WP4_2A"],
          [:global_means, "OUT_GB_INFER_C_31WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_31WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_10A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_11A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_12A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_14A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_2A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_4A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_6A"],
          [:global_means, "OUT_GB_INFER_C_31WP3_9A"],
          [:global_means, "OUT_GB_INFER_C_32WP2_102A"],
          [:global_means, "OUT_GB_INFER_C_32WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_33WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_33WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_33WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_34WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_34WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_1A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_3A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_408A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_4A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_6A"],
          [:global_means, "OUT_GB_INFER_C_34WP3_9A"],
          [:global_means, "OUT_GB_INFER_C_35WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_35WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_36WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_36WP2_102A"],
          [:global_means, "OUT_GB_INFER_C_37WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_37WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_38WP2_100A"],
          [:global_means, "OUT_GB_INFER_C_38WP2_102A"],
          [:global_means, "OUT_GB_INFER_C_38WP2_103A"],
          [:global_means, "OUT_GB_INFER_C_40WP2_101A"],
          [:global_means, "OUT_GB_INFER_C_40WP2_102A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_371A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_372A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_373A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_374A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_375A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_376A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_377A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_378A"],
          [:global_means, "OUT_GB_INPUT_C_20WP3_379A"],
          [:global_means, "OUT_GB_PROC_C_34WP3_12A"],
          [:global_means, "OUT_INCOME_CONT"],
          [:global_means, "PROVIDER_CASE_REFERENCE"],
          [:global_means, "PUI_CLIENT_INCOME_CONT"],
          [:global_means, "RB_VERSION_DATE_MEANS"],
          [:global_means, "RB_VERSION_NUMBER_MEANS"],
          [:global_means, "SA_SCREEN10_1WP1_NONMEANS"],
          [:global_means, "SA_SCREEN3_17WP2_1CAPASSESS"],
          [:global_merits, "_SYSTEM_PUI_CONTEXT"],
          [:global_merits, "_SYSTEM_PUI_URL"],
          [:global_merits, "APP_CARE_SUPERVISION"],
          [:global_merits, "APP_DIV_JUDSEP_DISSOLUTION_CP"],
          [:global_merits, "APP_INC_CHILD_ABDUCTION"],
          [:global_merits, "APP_INC_CHILDREN_PROCS"],
          [:global_merits, "APP_INC_SECURE_ACCOM"],
          [:global_merits, "APP_INCLUDES_IMMIGRATION_PROCS"],
          [:global_merits, "APP_INCLUDES_INQUEST_PROCS"],
          [:global_merits, "APP_INCLUDES_RELATED_PROCS"],
          [:global_merits, "APP_INCLUDES_SCA_PROCS"],
          [:global_merits, "APP_IS_SCA_RELATED"],
          [:global_merits, "APP_POTENTIAL_NON_MERITS"],
          [:global_merits, "APP_RELATES_EPO_EXTENDEPO_SAO"],
          [:global_merits, "APP_SCA_NON_MERITS_TESTED"],
          [:global_merits, "APPLICATION_CAN_BE_SUBMITTED"],
          [:global_merits, "ATTEND_URGENT_HEARING"],
          [:global_merits, "CAFCASS_EXPT_RPT_RECEIVED"],
          [:global_merits, "CASE_OWNER_COMPLEX_MERITS"],
          [:global_merits, "CASE_OWNER_IMMIGRATION"],
          [:global_merits, "CASE_OWNER_MENTAL_HEALTH"],
          [:global_merits, "CASE_OWNER_SCA"],
          [:global_merits, "CASE_OWNER_SCU"],
          [:global_merits, "CASE_OWNER_VHCC"],
          [:global_merits, "CERTIFICATE_PREDICTED_COSTS"],
          [:global_merits, "COPY_SEPARATE_STATEMENT"],
          [:global_merits, "CHILD_CLIENT"],
          [:global_merits, "CLIENT_CIVIL_PARTNER"],
          [:global_merits, "CLIENT_CIVIL_PARTNER_DISSOLVE"],
          [:global_merits, "CLIENT_COHABITING"],
          [:global_merits, "CLIENT_DIVORCED"],
          [:global_merits, "CLIENT_JUDICIALLY_SEPARATED"],
          [:global_merits, "CLIENT_MARITAL_STATUS"],
          [:global_merits, "CLIENT_MARRIED"],
          [:global_merits, "CLIENT_SINGLE"],
          [:global_merits, "CLIENT_WIDOWED"],
          [:global_merits, "CLINICAL_NEGLIGENCE"],
          [:global_merits, "COMMUNITY_CARE"],
          [:global_merits, "COPY_CA_FINDING_OF_FACT"],
          [:global_merits, "COPY_CA_POLICE_CAUTION"],
          [:global_merits, "COPY_DV_CONVICTION"],
          [:global_merits, "COPY_DV_IDVA"],
          [:global_merits, "COPY_DV_POLICE_CAUTION_2A"],
          [:global_merits, "COUNTY_COURT"],
          [:global_merits, "COURT_OF_APPEAL"],
          [:global_merits, "CRIME"],
          [:global_merits, "CROSS_BORDER_DISPUTES_GLOBAL"],
          [:global_merits, "CROWN_COURT"],
          [:global_merits, "CURRENT_CERT_EMERGENCY"],
          [:global_merits, "CURRENT_CERT_SUBSTANTIVE"],
          [:global_merits, "DATE_ASSESSMENT_STARTED"],
          [:global_merits, "DATE_CLIENT_VISITED_FIRM"],
          [:global_merits, "DEC_AGAINST_INSTRUCTIONS"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA02A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA10A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA11A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA12A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA13A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA14A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA15A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA2A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA3A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA5A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA6A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA7A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA8A"],
          [:global_merits, "DEC_CLIENT_TEXT_PARA9A"],
          [:global_merits, "DECLARATION_CLIENT_TEXT"],
          [:global_merits, "DECLARATION_IS_CLIENTS"],
          [:global_merits, "DECLARATION_IS_REPRESENTATIVES"],
          [:global_merits, "DP_WITH_JUDICIAL_REVIEW"],
          [:global_merits, "DV_FIN_ABUSE"],
          [:global_merits, "DV_LEGAL_HELP_PROVIDED"],
          [:global_merits, "ECF20A"],
          [:global_merits, "ECFCA_1A"],
          [:global_merits, "ECFCA_2A"],
          [:global_merits, "ECFCA_3A"],
          [:global_merits, "ECFCA_4A"],
          [:global_merits, "ECFCA_5A"],
          [:global_merits, "ECFCA_6A"],
          [:global_merits, "ECFCA_7A"],
          [:global_merits, "ECFCA_8A"],
          [:global_merits, "ECFDV_14A"],
          [:global_merits, "ECFDV_16A"],
          [:global_merits, "ECFDV_17A"],
          [:global_merits, "ECFDV_19A"],
          [:global_merits, "ECFDV_20A"],
          [:global_merits, "ECFDV_21A"],
          [:global_merits, "ECFDV_22A"],
          [:global_merits, "ECFDV_23A"],
          [:global_merits, "ECFDV_25A"],
          [:global_merits, "ECFDV_26A"],
          [:global_merits, "ECFDV_27A"],
          [:global_merits, "ECFDV_28A"],
          [:global_merits, "ECFDV_29A"],
          [:global_merits, "ECFDV_30A"],
          [:global_merits, "ECFDV_31A"],
          [:global_merits, "ECFDV_32A"],
          [:global_merits, "ECFDV_33A"],
          [:global_merits, "EDUCATION"],
          [:global_merits, "EMERGENCY_DEC_SIGNED"],
          [:global_merits, "EMERGENCY_DPS_APP_AMD"],
          [:global_merits, "EMPLOYMENT_APPEAL_TRIBUNAL"],
          [:global_merits, "FAM_CERT_PREDICTED_COSTS"],
          [:global_merits, "FIRST_TIER_TRIBUNAL_CARE_STAND"],
          [:global_merits, "FIRST_TIER_TRIBUNAL_IMM_ASY"],
          [:global_merits, "FIRST_TIER_TRIBUNAL_TAXATION"],
          [:global_merits, "HIGH_COURT"],
          [:global_merits, "HOUSING"],
          [:global_merits, "IMMIGRATION"],
          [:global_merits, "IMMIGRATION_CT_OF_APPEAL"],
          [:global_merits, "IMMIGRATION_QUESTION_APP"],
          [:global_merits, "ISSUE_URGENT_PROCEEDINGS"],
          [:global_merits, "LAR_CHILD_ABUSE_IDENTITY"],
          [:global_merits, "LAR_CHILD_ABUSE_RISK"],
          [:global_merits, "LAR_DV_VICTIM"],
          [:global_merits, "LAR_SCOPE_FLAG"],
          [:global_merits, "LEGAL_HELP_COSTS_TO_DATE"],
          [:global_merits, "LEGAL_HELP_PROVIDED"],
          [:global_merits, "LEGALLY_LINKED_SCU"],
          [:global_merits, "LEGALLY_LINKED_SIU"],
          [:global_merits, "LEGALLY_LINKED_VHCC"],
          [:global_merits, "LIMITATION_PERIOD_TO_EXPIRE"],
          [:global_merits, "MAGISTRATES_COURT"],
          [:global_merits, "MARITIAL_STATUS"],
          [:global_merits, "MATTER_IS_SWPI"],
          [:global_merits, "MEDIATION_APPLICABLE"],
          [:global_merits, "MENTAL_HEAL_QUESTION_APPLIES"],
          [:global_merits, "MENTAL_HEALTH"],
          [:global_merits, "MENTAL_HEALTH_REVIEW_TRIBUNAL"],
          [:global_merits, "MERITS_BACKLOG_REPORT_TAG"],
          [:global_merits, "MERITS_CERT_PREDICTED_COSTS"],
          [:global_merits, "MERITS_OPA_RELEASE"],
          [:global_merits, "MERITS_ROUTING_NAME"],
          [:global_merits, "MERITS_SUBMISSION_PAGE"],
          [:global_merits, "NEW_APPLICATION"],
          [:global_merits, "POA_OR_BILL_FLAG"],
          [:global_merits, "PRE_CERT_COSTS"],
          [:global_merits, "PREP_OF_STATEMENT_PAPERS"],
          [:global_merits, "PROCS_INCLUDE_CHILD"],
          [:global_merits, "PROPORTIONALITY_QUESTION_APP"],
          [:global_merits, "PROSCRIBED_ORG_APPEAL_COMM"],
          [:global_merits, "PROVIDER_CASE_REFERENCE"],
          [:global_merits, "PROVIDER_HAS_DP"],
          [:global_merits, "PUB_AUTH_QUESTION_APPLIES"],
          [:global_merits, "PUBLIC_LAW_NON_FAMILY"],
          [:global_merits, "RB_VERSION_DATE_MERITS"],
          [:global_merits, "RB_VERSION_NUMBER_MERITS"],
          [:global_merits, "REQUESTED_COST_LIMIT_OVER_25K"],
          [:global_merits, "RISK_SCA_PR"],
          [:global_merits, "ROUTING_COMPLEX_MERITS"],
          [:global_merits, "ROUTING_IMMIGRATION"],
          [:global_merits, "ROUTING_MENTAL_HEALTH"],
          [:global_merits, "ROUTING_SCU"],
          [:global_merits, "ROUTING_STD_FAMILY_MERITS"],
          [:global_merits, "ROUTING_VHCC"],
          [:global_merits, "SA_INTRODUCTION"],
          [:global_merits, "SCA_APPEAL_INCLUDED"],
          [:global_merits, "SCA_AUTO_GRANT"],
          [:global_merits, "SMOD_APPLICABLE_TO_MATTER"],
          [:global_merits, "SPECIAL_CHILDREN_ACT_APP"],
          [:global_merits, "SPECIAL_IMM_APPEAL_COMMISSION"],
          [:global_merits, "SUPREME_COURT"],
          [:global_merits, "UPPER_TRIBUNAL_IMM_ASY"],
          [:global_merits, "UPPER_TRIBUNAL_MENTAL_HEALTH"],
          [:global_merits, "UPPER_TRIBUNAL_OTHER"],
          [:global_merits, "URGENT_APPLICATION"],
          [:global_merits, "URGENT_APPLICATION_TAG"],
          [:global_merits, "URGENT_DIRECTIONS"],
          [:global_merits, "CHILD_MUST_BE_INCLUDED"],
          [:opponent_merits, "OPPONENT_DOB"],
          [:opponent_merits, "OPPONENT_DOB_MERITS"],
          [:proceeding_means, "PROC_UPPER_TRIBUNAL"],
          [:proceeding_merits, "ACTION_DAMAGES_AGAINST_POLICE"],
          [:proceeding_merits, "APPEAL_IN_SUPREME_COURT"],
          [:proceeding_merits, "CLIENT_BRINGING_OR_DEFENDING"],
          [:proceeding_merits, "CLIENT_DEFENDANT_3RD_PTY"],
          [:proceeding_merits, "CLIENT_INV_TYPE_APPELLANT"],
          [:proceeding_merits, "CLIENT_INV_TYPE_BRING_3RD_PTY"],
          [:proceeding_merits, "CLIENT_INV_TYPE_BRING_COUNTER"],
          [:proceeding_merits, "CLIENT_INV_TYPE_BRINGING_PROCS"],
          [:proceeding_merits, "CLIENT_INV_TYPE_CHILD"],
          [:proceeding_merits, "CLIENT_INV_TYPE_DEF_COUNTER"],
          [:proceeding_merits, "CLIENT_INV_TYPE_DEFEND_PROCS"],
          [:proceeding_merits, "CLIENT_INV_TYPE_INTERPLEADER"],
          [:proceeding_merits, "CLIENT_INV_TYPE_INTERVENOR"],
          [:proceeding_merits, "CLIENT_INV_TYPE_JOINED_PARTY"],
          [:proceeding_merits, "CLIENT_INV_TYPE_OTHER"],
          [:proceeding_merits, "CLIENT_INV_TYPE_PERSONAL_REP"],
          [:proceeding_merits, "CLIENT_INVOLVEMENT"],
          [:proceeding_merits, "COUNSEL_FEE_FAMILY"],
          [:proceeding_merits, "CROSS_BORDER_DISPUTES_C"],
          [:proceeding_merits, "DAMAGES_AGAINST_POLICE"],
          [:proceeding_merits, "DISBURSEMENT_COST_FAMILY"],
          [:proceeding_merits, "DOM_VIOLENCE_WAIVER_APPLIES"],
          [:proceeding_merits, "EXPERT_COST_FAMILY"],
          [:proceeding_merits, "FAM_PROSP_50_OR_BETTER"],
          [:proceeding_merits, "FAM_PROSP_BORDER_UNCERT_POOR"],
          [:proceeding_merits, "FAM_PROSP_BORDERLINE_UNCERT"],
          [:proceeding_merits, "FAM_PROSP_GOOD"],
          [:proceeding_merits, "FAM_PROSP_MARGINAL"],
          [:proceeding_merits, "FAM_PROSP_POOR"],
          [:proceeding_merits, "FAM_PROSP_UNCERTAIN"],
          [:proceeding_merits, "FAM_PROSP_VERY_GOOD"],
          [:proceeding_merits, "FAM_PROSP_VERY_POOR"],
          [:proceeding_merits, "HIGH_COST_CASE_ROUTING"],
          [:proceeding_merits, "IMMIGRATION_QUESTION_APPLIES"],
          [:proceeding_merits, "LEAD_PROCEEDING_MERITS"],
          [:proceeding_merits, "LEVEL_OF_SERV_FHH"],
          [:proceeding_merits, "LEVEL_OF_SERV_FR"],
          [:proceeding_merits, "LEVEL_OF_SERV_IH"],
          [:proceeding_merits, "LEVEL_OF_SERV_INQUEST"],
          [:proceeding_merits, "MATRIMONIAL_PROCEEDING"],
          [:proceeding_merits, "MATTER_TYPE_CHILD_ABDUCTION"],
          [:proceeding_merits, "MATTER_TYPE_PRIVATE_FAMILY"],
          [:proceeding_merits, "MATTER_TYPE_PUBLIC_FAMILY"],
          [:proceeding_merits, "MATTER_TYPE_STAND_ALONE"],
          [:proceeding_merits, "NEW_OR_EXISTING_MERITS"],
          [:proceeding_merits, "NON_QUANTIFIABLE_REMEDY"],
          [:proceeding_merits, "OVERWHELMING_IMPORTANCE"],
          [:proceeding_merits, "PRIVATE_FUNDING_APPLICABLE"],
          [:proceeding_merits, "PRIVATE_FUNDING_CONSIDERED"],
          [:proceeding_merits, "PROC_AVAILABLE_AMENDMENT_ONLY"],
          [:proceeding_merits, "PROC_CA_GATEWAY_APPLIES"],
          [:proceeding_merits, "PROC_CARE_SUPERV_OR_RELATED"],
          [:proceeding_merits, "PROC_CHILD_ABDUCTION"],
          [:proceeding_merits, "PROC_DEFAULT_LEVEL_OF_SERVICE"],
          [:proceeding_merits, "PROC_DELEGATED_FUNCTIONS_DATE"],
          [:proceeding_merits, "PROC_DV_GATEWAY_APPLIES"],
          [:proceeding_merits, "PROC_FIN_REP_CATEGORY"],
          [:proceeding_merits, "PROC_IMMIGRATION_RELATED"],
          [:proceeding_merits, "PROC_INVOLVING_CHILDREN"],
          [:proceeding_merits, "PROC_INVOLVING_FIN_AND_PROP"],
          [:proceeding_merits, "PROC_INVOLVING_INJUNCTION"],
          [:proceeding_merits, "PROC_IS_MERITS_TESTED"],
          [:proceeding_merits, "PROC_IS_SCA_APPEAL"],
          [:proceeding_merits, "PROC_IS_SCA_OR_RELATED"],
          [:proceeding_merits, "PROC_LAR_GATEWAY"],
          [:proceeding_merits, "PROC_MATTER_TYPE_DESC"],
          [:proceeding_merits, "PROC_MATTER_TYPE_MEANING"],
          [:proceeding_merits, "PROC_MEANING"],
          [:proceeding_merits, "PROC_OUTCOME_NO_OUTCOME"],
          [:proceeding_merits, "PROC_OUTCOME_RECORDED"],
          [:proceeding_merits, "PROC_POSSESSION"],
          [:proceeding_merits, "PROC_PREDICTED_COST_FAMILY"],
          [:proceeding_merits, "PROC_REGISTER_FOREIGN_ORDER"],
          [:proceeding_merits, "PROC_RELATED_PROCEEDING"],
          [:proceeding_merits, "PROC_RELATED_SCA_OR_RELATED"],
          [:proceeding_merits, "PROC_SCHED1_TRUE"],
          [:proceeding_merits, "PROC_SUBJECT_TO_DP_CHECK"],
          [:proceeding_merits, "PROC_SUBJECT_TO_MEDIATION"],
          [:proceeding_merits, "PROC_UPPER_TRIBUNAL"],
          [:proceeding_merits, "PROCEEDING_CASE_OWNER_SCU"],
          [:proceeding_merits, "PROCEEDING_DESCRIPTION"],
          [:proceeding_merits, "PROCEEDING_INCLUDES_CHILD"],
          [:proceeding_merits, "PROCEEDING_JUDICIAL_REVIEW"],
          [:proceeding_merits, "PROCEEDING_LIMITATION_DESC"],
          [:proceeding_merits, "PROCEEDING_LIMITATION_MEANING"],
          [:proceeding_merits, "PROCEEDING_STAND_ALONE"],
          [:proceeding_merits, "PROCEEDING_TYPE"],
          [:proceeding_merits, "PROFIT_COST_FAMILY"],
          [:proceeding_merits, "PROPORTIONALITY_QUESTION"],
          [:proceeding_merits, "PROSPECTS_OF_SUCCESS"],
          [:proceeding_merits, "ROUTING_FOR_PROCEEDING"],
          [:proceeding_merits, "SCA_APPEAL_FINAL_ORDER"],
          [:proceeding_merits, "SIGNIFICANT_WIDER_PUB_INTEREST"],
          [:proceeding_merits, "SMOD_APPLICABLE"],
          [:proceeding_merits, "WORK_IN_SCH_ONE"],
          [:bank_accounts_entity, "BANKACC_INPUT_C_7WP2_18A"],
          [:bank_accounts_entity, "BANKACC_INPUT_N_7WP2_5A"],
          [:bank_accounts_entity, "BANKACC_INPUT_T_7WP2_3A"],
          [:bank_accounts_entity, "BANKACC_INPUT_T_7WP2_4A"],
          [:bank_accounts_entity, "BANKACC_INPUT_T_7WP2_6A"],
          [:global_merits, "COPY_WARNING_LETTER"],
          [:global_merits, "GB_DECL_T_38WP3_118A"],
          [:global_merits, "GB_INPUT_B_39WP3_9A"],
          [:global_merits, "GB_INPUT_T_6WP1_1A"],
          [:global_merits, "GB_INPUT_T_6WP1_2A"],
          [:global_merits, "SA_SCREEN2_6WP1_PASSPORTEDBEN"],
          [:global_merits, "SA_SCREEN4_6WP1_PASSPORT"],
        ]
      end

      def false_attributes
        [
          [:global_means, "GB_INPUT_B_11WP3_367A"],
          [:global_means, "GB_INPUT_B_1WP2_14A"],
          [:global_means, "GB_INPUT_B_1WP2_22A"],
          [:global_means, "GB_INPUT_B_1WP2_27A"],
          [:global_means, "GB_INPUT_B_17WP2_7A"],
          [:global_means, "GB_INPUT_B_17WP2_8A"],
          [:global_means, "GB_INPUT_B_18WP2_2A"],
          [:global_means, "GB_INPUT_B_18WP2_4A"],
          [:global_means, "GB_INPUT_B_18WP2_6A"],
          [:global_means, "GB_INPUT_B_1WP1_2A"],
          [:global_means, "GB_INPUT_B_1WP4_1B"],
          [:global_means, "GB_INPUT_B_1WP4_2B"],
          [:global_means, "GB_INPUT_B_1WP4_3B"],
          [:global_means, "GB_INPUT_B_39WP3_70B"],
          [:global_means, "GB_INPUT_B_41WP3_40A"],
          [:global_means, "GB_INPUT_B_4WP3_209A"],
          [:global_means, "GB_INPUT_B_5WP1_22A"],
          [:global_means, "GB_INPUT_B_5WP1_3A"],
          [:global_means, "GB_PROC_B_39WP3_14A"],
          [:global_means, "GB_PROC_B_39WP3_15A"],
          [:global_means, "GB_PROC_B_39WP3_16A"],
          [:global_means, "GB_PROC_B_39WP3_17A"],
          [:global_means, "GB_PROC_B_39WP3_18A"],
          [:global_means, "GB_PROC_B_39WP3_19A"],
          [:global_means, "GB_PROC_B_39WP3_1A"],
          [:global_means, "GB_PROC_B_39WP3_20A"],
          [:global_means, "GB_PROC_B_39WP3_21A"],
          [:global_means, "GB_PROC_B_39WP3_22A"],
          [:global_means, "GB_PROC_B_39WP3_23A"],
          [:global_means, "GB_PROC_B_39WP3_24A"],
          [:global_means, "GB_PROC_B_39WP3_25A"],
          [:global_means, "GB_PROC_B_39WP3_29A"],
          [:global_means, "GB_PROC_B_39WP3_2A"],
          [:global_means, "GB_PROC_B_39WP3_30A"],
          [:global_means, "GB_PROC_B_39WP3_31A"],
          [:global_means, "GB_PROC_B_39WP3_32A"],
          [:global_means, "GB_PROC_B_39WP3_33A"],
          [:global_means, "GB_PROC_B_39WP3_34A"],
          [:global_means, "GB_PROC_B_39WP3_35A"],
          [:global_means, "GB_PROC_B_39WP3_36A"],
          [:global_means, "GB_PROC_B_39WP3_37A"],
          [:global_means, "GB_PROC_B_39WP3_38A"],
          [:global_means, "GB_PROC_B_39WP3_39A"],
          [:global_means, "GB_PROC_B_39WP3_40A"],
          [:global_means, "GB_PROC_B_39WP3_41A"],
          [:global_means, "GB_PROC_B_39WP3_42A"],
          [:global_means, "GB_PROC_B_39WP3_46A"],
          [:global_means, "GB_PROC_B_39WP3_47A"],
          [:global_means, "GB_PROC_B_39WP3_7A"],
          [:global_means, "GB_PROC_B_39WP3_8A"],
          [:global_means, "GB_PROC_B_40WP3_10A"],
          [:global_means, "GB_PROC_B_40WP3_13A"],
          [:global_means, "GB_PROC_B_40WP3_15A"],
          [:global_means, "GB_PROC_B_40WP3_17A"],
          [:global_means, "GB_PROC_B_40WP3_19A"],
          [:global_means, "GB_PROC_B_40WP3_1A"],
          [:global_means, "GB_PROC_B_40WP3_21A"],
          [:global_means, "GB_PROC_B_40WP3_23A"],
          [:global_means, "GB_PROC_B_40WP3_25A"],
          [:global_means, "GB_PROC_B_40WP3_27A"],
          [:global_means, "GB_PROC_B_40WP3_29A"],
          [:global_means, "GB_PROC_B_40WP3_2A"],
          [:global_means, "GB_PROC_B_40WP3_31A"],
          [:global_means, "GB_PROC_B_40WP3_33A"],
          [:global_means, "GB_PROC_B_40WP3_35A"],
          [:global_means, "GB_PROC_B_40WP3_39A"],
          [:global_means, "GB_PROC_B_40WP3_3A"],
          [:global_means, "GB_PROC_B_40WP3_40A"],
          [:global_means, "GB_PROC_B_40WP3_41A"],
          [:global_means, "GB_PROC_B_40WP3_42A"],
          [:global_means, "GB_PROC_B_40WP3_43A"],
          [:global_means, "GB_PROC_B_40WP3_44A"],
          [:global_means, "GB_PROC_B_40WP3_45A"],
          [:global_means, "GB_PROC_B_40WP3_46A"],
          [:global_means, "GB_PROC_B_40WP3_47A"],
          [:global_means, "GB_PROC_B_40WP3_48A"],
          [:global_means, "GB_PROC_B_40WP3_49A"],
          [:global_means, "GB_PROC_B_40WP3_4A"],
          [:global_means, "GB_PROC_B_40WP3_50A"],
          [:global_means, "GB_PROC_B_40WP3_51A"],
          [:global_means, "GB_PROC_B_40WP3_52A"],
          [:global_means, "GB_PROC_B_40WP3_53A"],
          [:global_means, "GB_PROC_B_40WP3_54A"],
          [:global_means, "GB_PROC_B_40WP3_55A"],
          [:global_means, "GB_PROC_B_40WP3_56A"],
          [:global_means, "GB_PROC_B_40WP3_57A"],
          [:global_means, "GB_PROC_B_40WP3_58A"],
          [:global_means, "GB_PROC_B_40WP3_9A"],
          [:global_means, "GB_PROC_B_41WP3_10A"],
          [:global_means, "GB_PROC_B_41WP3_11A"],
          [:global_means, "GB_PROC_B_41WP3_12A"],
          [:global_means, "GB_PROC_B_41WP3_13A"],
          [:global_means, "GB_PROC_B_41WP3_14A"],
          [:global_means, "GB_PROC_B_41WP3_15A"],
          [:global_means, "GB_PROC_B_41WP3_16A"],
          [:global_means, "GB_PROC_B_41WP3_17A"],
          [:global_means, "GB_PROC_B_41WP3_18A"],
          [:global_means, "GB_PROC_B_41WP3_1A"],
          [:global_means, "GB_PROC_B_41WP3_20A"],
          [:global_means, "GB_PROC_B_41WP3_2A"],
          [:global_means, "GB_PROC_B_41WP3_3A"],
          [:global_means, "GB_PROC_B_41WP3_4A"],
          [:global_means, "GB_PROC_B_41WP3_5A"],
          [:global_means, "GB_PROC_B_41WP3_6A"],
          [:global_means, "GB_PROC_B_41WP3_7A"],
          [:global_means, "GB_PROC_B_41WP3_8A"],
          [:global_means, "GB_PROC_B_41WP3_9A"],
          [:global_means, "GB_ROUT_B_43WP3_13A"],
          [:global_means, "HIGH_PROFILE"],
          [:global_means, "LAR_PROC_B_39WP3_53A"],
          [:global_means, "LAR_PROC_B_39WP3_54A"],
          [:global_means, "LAR_PROC_B_40WP3_29A"],
          [:global_means, "LAR_PROC_B_40WP3_30A"],
          [:global_means, "LAR_PROC_B_40WP3_31A"],
          [:global_means, "LAR_PROC_B_40WP3_32A"],
          [:global_means, "LAR_INPUT_B_37WP2_4A"],
          [:global_means, "LAR_PER_RES_INPUT_B_37WP2_7A"],
          [:global_means, "MEANS_EVIDENCE_REQD"],
          [:global_merits, "ACTION_AGAINST_POLICE"],
          [:global_merits, "ACTUAL_LIKELY_COSTS_EXCEED_25K"],
          [:global_merits, "AMENDMENT"],
          [:global_merits, "APP_BROUGHT_BY_PERSONAL_REP"],
          [:global_merits, "CLIENT_HAS_RECEIVED_LA_BEFORE"],
          [:global_merits, "COST_LIMIT_CHANGED"],
          [:global_merits, "COURT_ATTEND_IN_LAST_12_MONTHS"],
          [:global_merits, "DECLARATION_IDENTIFIER"],
          [:global_merits, "ECF_FLAG"],
          [:global_merits, "ECFDV_18A"],
          [:global_merits, "EVID_DEC_AGAINST_INSTRUCTIONS"],
          [:global_merits, "EVIDENCE_AMD_CORRESPONDENCE"],
          [:global_merits, "EVIDENCE_AMD_COUNSEL_OPINION"],
          [:global_merits, "EVIDENCE_AMD_COURT_ORDER"],
          [:global_merits, "EVIDENCE_AMD_EXPERT_RPT"],
          [:global_merits, "EVIDENCE_AMD_PLEADINGS"],
          [:global_merits, "EVIDENCE_AMD_SOLICITOR_RPT"],
          [:global_merits, "EVIDENCE_CA_CRIME_PROCS"],
          [:global_merits, "EVIDENCE_CA_FINDING_FACT"],
          [:global_merits, "EVIDENCE_CA_INJ_PSO"],
          [:global_merits, "EVIDENCE_CA_POLICE_BAIL"],
          [:global_merits, "EVIDENCE_CA_POLICE_CAUTION"],
          [:global_merits, "EVIDENCE_CA_PROTECTIVE_INJ"],
          [:global_merits, "EVIDENCE_CA_SOCSERV_ASSESS"],
          [:global_merits, "EVIDENCE_CA_SOCSERV_LTTR"],
          [:global_merits, "EVIDENCE_CA_UNSPENT_CONVICTION"],
          [:global_merits, "EVIDENCE_COPY_PR_ORDER"],
          [:global_merits, "EVIDENCE_DV_CONVICTION"],
          [:global_merits, "EVIDENCE_DV_COURT_ORDER"],
          [:global_merits, "EVIDENCE_DV_CRIM_PROCS_2A"],
          [:global_merits, "EVIDENCE_DV_DVPN_2"],
          [:global_merits, "EVIDENCE_DV_FIN_ABUSE"],
          [:global_merits, "EVIDENCE_DV_FINDING_FACT_2A"],
          [:global_merits, "EVIDENCE_DV_HEALTH_LETTER"],
          [:global_merits, "EVIDENCE_DV_HOUSING_AUTHORITY"],
          [:global_merits, "EVIDENCE_DV_IDVA"],
          [:global_merits, "EVIDENCE_DV_IMMRULES_289A"],
          [:global_merits, "EVIDENCE_DV_PARTY_ON_BAIL_2A"],
          [:global_merits, "EVIDENCE_DV_POLICE_CAUTION_2A"],
          [:global_merits, "EVIDENCE_DV_PROT_INJUNCT"],
          [:global_merits, "EVIDENCE_DV_PUB_BODY"],
          [:global_merits, "EVIDENCE_DV_PUBLIC_BODY"],
          [:global_merits, "EVIDENCE_DV_REFUGE"],
          [:global_merits, "EVIDENCE_DV_SUPP_SERVICE"],
          [:global_merits, "EVIDENCE_DV_SUPPORT_ORG"],
          [:global_merits, "EVIDENCE_DV_UNDERTAKING_2A"],
          [:global_merits, "EVIDENCE_EXISTING_COUNSEL_OP"],
          [:global_merits, "EVIDENCE_EXISTING_CT_ORDER"],
          [:global_merits, "EVIDENCE_EXISTING_EXPERT_RPT"],
          [:global_merits, "EVIDENCE_EXISTING_STATEMENT"],
          [:global_merits, "EVIDENCE_EXPERT_REPORT"],
          [:global_merits, "EVIDENCE_ICACU_LETTER"],
          [:global_merits, "EVIDENCE_IQ_CORONER_CORR"],
          [:global_merits, "EVIDENCE_IQ_COSTS_SCHEDULE"],
          [:global_merits, "EVIDENCE_IQ_REPORT_ON_DEATH"],
          [:global_merits, "EVIDENCE_LETTER_BEFORE_ACTION"],
          [:global_merits, "EVIDENCE_MEDIATOR_APP7A"],
          [:global_merits, "EVIDENCE_OMBUDSMAN_COMP_RPT"],
          [:global_merits, "EVIDENCE_PLEADINGS_REQUIRED"],
          [:global_merits, "EVIDENCE_PR_AGREEMENT"],
          [:global_merits, "EVIDENCE_PRE_ACTION_DISCLOSURE"],
          [:global_merits, "EVIDENCE_RELEVANT_CORR_ADR"],
          [:global_merits, "EVIDENCE_RELEVANT_CORR_SETTLE"],
          [:global_merits, "EVIDENCE_WARNING_LETTER"],
          [:global_merits, "EXISTING_COUNSEL_OPINION"],
          [:global_merits, "EXISTING_EXPERT_REPORTS"],
          [:global_merits, "FH_LOWER_PROVIDED"],
          [:global_merits, "HIGH_PROFILE"],
          [:global_merits, "MENTAL_HEAL_ACT_MENTAL_CAP_ACT"],
          [:global_merits, "MERITS_EVIDENCE_REQD"],
          [:global_merits, "NEGOTIATION_CORRESPONDENCE"],
          [:global_merits, "OTHER_PARTIES_MAY_BENEFIT"],
          [:global_merits, "OTHERS_WHO_MAY_BENEFIT"],
          [:global_merits, "PROCS_ARE_BEFORE_THE_COURT"],
          [:global_merits, "UPLOAD_SEPARATE_STATEMENT"],
          [:global_merits, "URGENT_FLAG"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_CORR"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_COUNSEL"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_CT_ORDER"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_EXPERT"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_PLEAD"],
          [:global_merits, "NON_MAND_EVIDENCE_AMD_SOLS_RPT"],
          [:global_merits, "NON_MAND_EVIDENCE_CORR_ADR"],
          [:global_merits, "NON_MAND_EVIDENCE_CORR_SETTLE"],
          [:global_merits, "NON_MAND_EVIDENCE_COUNSEL_OP"],
          [:global_merits, "NON_MAND_EVIDENCE_CTORDER"],
          [:global_merits, "NON_MAND_EVIDENCE_EXPERT_EXIST"],
          [:global_merits, "NON_MAND_EVIDENCE_EXPERT_RPT"],
          [:global_merits, "NON_MAND_EVIDENCE_ICA_LETTER"],
          [:global_merits, "NON_MAND_EVIDENCE_LTTR_ACTION"],
          [:global_merits, "NON_MAND_EVIDENCE_OMBUD_RPT"],
          [:global_merits, "NON_MAND_EVIDENCE_PLEADINGS"],
          [:global_merits, "NON_MAND_EVIDENCE_PRE_ACT_DISC"],
          [:global_merits, "NON_MAND_EVIDENCE_SEP_STATE"],
          [:global_merits, "NON_MAND_EVIDENCE_WARNING_LTTR"],
          [:opponent_merits, "PARTY_IS_A_CHILD"],
          [:opponent_merits, "RELATIONSHIP_CASE_AGENT"],
          [:opponent_merits, "RELATIONSHIP_CASE_BENEFICIARY"],
          [:opponent_merits, "RELATIONSHIP_CASE_CHILD"],
          [:opponent_merits, "RELATIONSHIP_CASE_GAL"],
          [:opponent_merits, "RELATIONSHIP_CASE_INT_PARTY"],
          [:opponent_merits, "RELATIONSHIP_CASE_INTERVENOR"],
          [:opponent_merits, "RELATIONSHIP_CHILD"],
          [:opponent_merits, "RELATIONSHIP_CIVIL_PARTNER"],
          [:opponent_merits, "RELATIONSHIP_CUSTOMER"],
          [:opponent_merits, "RELATIONSHIP_EMPLOYEE"],
          [:opponent_merits, "RELATIONSHIP_EMPLOYER"],
          [:opponent_merits, "RELATIONSHIP_EX_CIVIL_PARTNER"],
          [:opponent_merits, "RELATIONSHIP_EX_HUSBAND_WIFE"],
          [:opponent_merits, "RELATIONSHIP_GRANDPARENT"],
          [:opponent_merits, "RELATIONSHIP_HUSBAND_WIFE"],
          [:opponent_merits, "RELATIONSHIP_LANDLORD"],
          [:opponent_merits, "RELATIONSHIP_LEGAL_GUARDIAN"],
          [:opponent_merits, "RELATIONSHIP_LOCAL_AUTHORITY"],
          [:opponent_merits, "RELATIONSHIP_MEDICAL_PRO"],
          [:opponent_merits, "RELATIONSHIP_OTHER_FAM_MEMBER"],
          [:opponent_merits, "RELATIONSHIP_PARENT"],
          [:opponent_merits, "RELATIONSHIP_PROPERTY_OWNER"],
          [:opponent_merits, "RELATIONSHIP_SOL_BARRISTER"],
          [:opponent_merits, "RELATIONSHIP_STEP_PARENT"],
          [:opponent_merits, "RELATIONSHIP_SUPPLIER"],
          [:opponent_merits, "RELATIONSHIP_TENANT"],
          [:opponent_merits, "RELATIONSHIP_NONE"],
          [:opponent_merits, "OTHER_PARTY_ORG"],
          [:proceeding_merits, "UNLAWFUL_REMOVAL_OF_CHILDREN_C"],
        ]
      end
    end
  end
end
