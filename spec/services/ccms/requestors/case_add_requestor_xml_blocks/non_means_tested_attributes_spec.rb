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
            :with_under_18_applicant_and_no_partner,
            :with_skipped_benefit_check_result,
            :with_non_means_tested_state_machine,
            :with_cfe_empty_result,
            :with_merits_statement_of_case,
            :with_opponent,
            :with_parties_mental_capacity,
            :with_domestic_abuse_summary,
            :with_incident,
            :with_chances_of_success,
            :with_merits_submitted,
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
              expect(block).to have_text_response legal_aid_application.applicant.correspondence_address_for_ccms.postcode
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

            it "populate OTHER_PARTY_TYPE" do
              block = XmlExtractor.call(xml, entity, "OTHER_PARTY_TYPE")
              expect(block).to have_text_response "PERSON"
            end

            it "populates OTHER_PARTY_PERSON" do
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
        load_ccms_attribute_array("non_means_tested_omitted.csv")
      end

      def false_attributes
        load_ccms_attribute_array("non_means_tested_false.csv")
      end
    end
  end
end
