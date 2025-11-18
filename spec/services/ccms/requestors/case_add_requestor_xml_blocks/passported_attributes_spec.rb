require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe CaseAddRequestor, :ccms do
      describe "XML request" do
        let(:expected_tx_id) { "201904011604570390059770666" }
        let(:firm) { create(:firm, name: "Firm1") }
        let(:office) { create(:office, firm:) }
        let(:provider) do
          create(:provider,
                 firm:,
                 selected_office: office,
                 username: 4_953_649)
        end

        let!(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_everything,
                 :with_applicant_and_no_partner,
                 :with_positive_benefit_check_result,
                 set_lead_proceeding: :da001,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider:,
                 office:)
        end

        let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:opponent) { legal_aid_application.opponents.first }
        let(:domestic_abuse_summary) { legal_aid_application.domestic_abuse_summary }
        let(:parties_mental_capacity) { legal_aid_application.parties_mental_capacity }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let!(:success_prospect) { :likely }

        before do
          create(:chances_of_success, success_prospect:, success_prospect_details: "details", proceeding:)
          create(:cfe_v3_result, submission: cfe_submission)
          allow_any_instance_of(Proceeding).to receive(:proceeding_case_id).and_return(55_000_001)
        end

        # uncomment this example to create a file of the payload for manual inspection
        # it 'create example payload file' do
        #   filename = Rails.root.join('tmp/generated_non_means_tested_ccms_payload.xml')
        #   File.open(filename, 'w') { |f| f.puts xml }
        #   expect(File.exist?(filename)).to be true
        # end

        describe "DevolvedPowersDate" do
          context "when it's a Substantive case" do
            it "is omitted" do
              block = XmlExtractor.call(xml, :devolved_powers_date)
              expect(block).not_to be_present, "Expected block for attribute DevolvedPowersDate not to be generated, but was \n #{block}"
            end
          end

          context "when it's a Delegated Functions case" do
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

        describe "CHILD_PARTIES_C" do
          context "when it's a section8 proceeding" do
            before { allow_any_instance_of(Proceeding).to receive(:section8?).and_return true }

            it "is true" do
              block = XmlExtractor.call(xml, :proceeding_merits, "CHILD_PARTIES_C")
              expect(block).to have_boolean_response(true)
            end
          end

          context "when it's a domestic abuse proceeding" do
            before { allow_any_instance_of(Proceeding).to receive(:section8?).and_return false }

            it "is false" do
              block = XmlExtractor.call(xml, :proceeding_merits, "CHILD_PARTIES_C")
              expect(block).to have_boolean_response(false)
            end
          end
        end

        describe "PASSPORTED_NINO" do
          let(:applicant) { legal_aid_application.applicant }

          it "generates PASSPORTED NINO in global merits" do
            block = XmlExtractor.call(xml, :global_means, "PASSPORTED_NINO")
            expect(block).to have_text_response applicant.national_insurance_number
            expect(block).to be_user_defined
          end
        end

        describe "GB_INFER_T_6WP1_66A" do
          it "generates GB_INFER_T_6WP1_66A in global merits" do
            block = XmlExtractor.call(xml, :global_merits, "GB_INFER_T_6WP1_66A")
            expect(block).to have_text_response "CLIENT"
            expect(block).not_to be_user_defined
          end
        end

        describe "CLIENT_ELIGIBILITY and PUI_CLIENT_ELIGIBILITY" do
          context "when the cfe result is eligible" do
            let(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns In Scope" do
              block = XmlExtractor.call(xml, :global_means, "CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "In Scope"
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "In Scope"
            end
          end

          context "when the cfe result is not_eligible" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result, :not_eligible, submission: cfe_submission)
            end

            it "returns Out Of Scope" do
              block = XmlExtractor.call(xml, :global_means, "CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "Out Of Scope"
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "Out Of Scope"
            end
          end

          context "when the cfe result is contribution_required" do
            let(:cfe_result) { create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission) }

            it "returns In Scope" do
              block = XmlExtractor.call(xml, :global_means, "CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "In Scope"
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_ELIGIBILITY")
              expect(block).to have_text_response "In Scope"
            end
          end

          context "when the cfe result has an invalid response" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result,
                     :with_unknown_result,
                     submission: cfe_submission)
            end

            it "raises" do
              expect { xml }.to raise_error RuntimeError, "Unexpected assessment result: unknown"
            end
          end
        end

        describe "INCOME_CONT" do
          it "always returns zero" do
            block = XmlExtractor.call(xml, :global_means, "INCOME_CONT")
            expect(block).to have_currency_response "0.00"
          end
        end

        describe "CAP_CONT and similar attributes" do
          let(:attributes) { %w[PUI_CLIENT_CAP_CONT CAP_CONT OUT_CAP_CONT] }

          context "when the cfe result is eligble" do
            let(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns zero" do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response "0.00"
              end
            end
          end

          context "when the cfe result is not eligible" do
            let(:cfe_result) { create(:cfe_v3_result, :not_eligible, submission: cfe_submission) }

            it "returns zero" do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response "0.00"
              end
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_CAP_CONT")
              expect(block).to have_currency_response "0.00"
            end
          end

          context "when the cfe result is contribution_required" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission)
            end

            it "returns the capital contribution" do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response "465.66"
              end
            end
          end
        end

        describe "valuable possessions entity" do
          context "when valuable possessions are present" do
            it "creates the entity" do
              entity_block = XmlExtractor.call(xml, :valuable_possessions_entity)
              expect(entity_block).to be_present
            end
          end

          context "when no valuable possessions are present" do
            before { legal_aid_application.other_assets_declaration.valuable_items_value = nil }

            it "does not generate the bank accounts entity" do
              block = XmlExtractor.call(xml, :valuable_possessions_entity)
              expect(block).not_to be_present, "Expected block for valuable possessions entity not to be generated, but was \n #{block}"
            end

            it "assigns the sequence number of 1 to the next entity" do
              bank_accounts_sequence = XmlExtractor.call(xml, :bank_accounts_sequence).text.to_i
              expect(bank_accounts_sequence).to eq 1
            end
          end
        end

        describe "bank accounts entity" do
          context "when bank accounts are present" do
            it "creates the entity" do
              entity_block = XmlExtractor.call(xml, :bank_accounts_entity)
              expect(entity_block).to be_present
            end
          end

          context "when no bank accounts are present" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     vehicles: [],
                     office:)
            end

            it "does not generate the bank accounts entity" do
              block = XmlExtractor.call(xml, :bank_accounts_entity)
              expect(block).not_to be_present, "Expected block for bank accounts entity not to be generated, but was \n #{block}"
            end

            it "assigns the sequence number to the next entity one higher than that for valuable possessions" do
              valuable_possessions_entity = XmlExtractor.call(xml, :valuable_possessions_entity)
              doc = Nokogiri::XML(valuable_possessions_entity.to_s)
              valuable_possessions_sequence = doc.xpath("//SequenceNumber").text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath("//SequenceNumber").text.to_i
              expect(means_proceeding_sequence).to eq valuable_possessions_sequence + 1
            end
          end
        end

        describe "car and vehicle entity" do
          context "when a car or vehicle is present" do
            it "does not create the entity" do
              entity_block = XmlExtractor.call(xml, :vehicle_entity)
              expect(entity_block).not_to be_present
            end
          end

          context "when no car or vehicle is present" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     with_bank_accounts: 2,
                     vehicles: [],
                     office:)
            end

            it "does not generate the vehicle entity" do
              block = XmlExtractor.call(xml, :vehicle_entity)
              expect(block).not_to be_present, "Expected block for vehicle entity not to be generated, but was \n #{block}"
            end

            it "assigns the sequence number to the next entity one higher than that for bank accounts" do
              bank_account_sequence = XmlExtractor.call(xml, :bank_accounts_sequence).text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath("//SequenceNumber").text.to_i
              expect(means_proceeding_sequence).to eq bank_account_sequence + 1
            end
          end
        end

        describe "wage slips entity" do
          context "when no wage slips are present" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     office:)
            end

            it "does not generate the wage slips entity" do
              block = XmlExtractor.call(xml, :wage_slip_entity)
              expect(block).not_to be_present, "Expected block for wage slips entity not to be generated, but was \n #{block}"
            end

            it "assigns the sequence number to the next entity one higher than that for valuable_possessions" do
              possession_entity = XmlExtractor.call(xml, :valuable_possessions_entity)
              doc = Nokogiri::XML(possession_entity.to_s)
              possession_sequence = doc.xpath("//SequenceNumber").text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath("//SequenceNumber").text.to_i
              expect(means_proceeding_sequence).to eq possession_sequence + 1
            end
          end
        end

        describe "employment entity" do
          context "when no employment details are present" do
            it "does not generate the employment entity" do
              block = XmlExtractor.call(xml, :employment_entity)
              expect(block).not_to be_present, "Expected block for wage slips entity not to be generated, but was \n #{block}"
            end
          end
        end

        describe "ProceedingCaseId" do
          let(:proceeding_case_id) { legal_aid_application.proceedings.first.proceeding_case_p_num }

          describe "ProceedingCaseId section" do
            it "has a p number" do
              block = XmlExtractor.call(xml, :proceeding_case_id)
              expect(block.text).to eq proceeding_case_id
            end
          end

          describe "in merits assessment block" do
            it "has a p number" do
              block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_ID")
              expect(block).to have_text_response(proceeding_case_id)
            end
          end

          describe "in means assessment block" do
            it "has a p number" do
              block = XmlExtractor.call(xml, :proceeding_means, "PROCEEDING_ID")
              expect(block).to have_text_response(proceeding_case_id)
            end
          end
        end

        describe "APPLICATION_CASE_REF" do
          it "inserts the case reference from the submission record the global means sections" do
            block = XmlExtractor.call(xml, :global_means, "APPLICATION_CASE_REF")
            expect(block).to have_text_response submission.case_ccms_reference
          end

          it "inserts the case reference from the submission record the global merits sections" do
            block = XmlExtractor.call(xml, :global_merits, "APPLICATION_CASE_REF")
            expect(block).to have_text_response ccms_reference
          end
        end

        describe "FAMILY_PROSPECTS_OF_SUCCESS" do
          context "when there is a likely success prospect" do
            it "returns the ccms equivalent prospect of success for likely" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Good"
            end
          end

          context "when there is a marginal success prospect" do
            let(:success_prospect) { "marginal" }

            it "returns the ccms equivalent prospect of success for marginal" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Marginal"
            end
          end

          context "when there is a not_known success prospect" do
            let(:success_prospect) { "not_known" }

            it "returns the ccms equivalent prospect of success for not_known" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Uncertain"
            end
          end

          context "when there is a poor success prospect" do
            let(:success_prospect) { "poor" }

            it "returns the ccms equivalent prospect of success for poor" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Poor"
            end
          end

          context "when there is a borderline success prospect" do
            let(:success_prospect) { "borderline" }

            it "returns the ccms equivalent prospect of success for borderline" do
              block = XmlExtractor.call(xml, :proceeding_merits, "FAMILY_PROSPECTS_OF_SUCCESS")
              expect(block).to have_text_response "Borderline"
            end
          end
        end

        describe "DELEGATED_FUNCTIONS_DATE blocks" do
          context "when delegated functions are used" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it "generates the delegated functions block in the means assessment section" do
              block = XmlExtractor.call(xml, :global_means, "DELEGATED_FUNCTIONS_DATE")
              expect(block).to have_date_response(Time.zone.today.strftime("%d-%m-%Y"))
            end

            it "generates the delegated functions block in the merits assessment section" do
              block = XmlExtractor.call(xml, :global_merits, "DELEGATED_FUNCTIONS_DATE")
              expect(block).to have_date_response(Time.zone.today.strftime("%d-%m-%Y"))
            end
          end

          context "when delegated functions are not used" do
            it "does not generate the delegated functions block in the means assessment section" do
              block = XmlExtractor.call(xml, :global_means, "DELEGATED_FUNCTIONS_DATE")
              expect(block).not_to be_present
            end

            it "does not generates the delegated functions block in the merits assessment section" do
              block = XmlExtractor.call(xml, :global_merits, "DELEGATED_FUNCTIONS_DATE")
              expect(block).not_to be_present
            end
          end
        end

        describe "EMERGENCY_FC_CRITERIA" do
          it "inserts emergency_fc criteria as hard coded string" do
            block = XmlExtractor.call(xml, :global_merits, "EMERGENCY_FC_CRITERIA")
            expect(block).to have_text_response "."
          end
        end

        describe "URGENT_HEARING_DATE" do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }

          it "inserts ccms submission date as string" do
            block = XmlExtractor.call(xml, :global_merits, "URGENT_HEARING_DATE")
            expect(block).to have_date_response legal_aid_application.calculation_date.strftime("%d-%m-%Y")
          end
        end

        describe "GB_INPUT_B_2WP2_1A - Applicant is a beneficiary of a will?" do
          context "when the applicant is not the beneficiary of a will" do
            before { legal_aid_application.other_assets_declaration = create :other_assets_declaration, :all_nil }

            it "inserts false into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_2WP2_1A")
              expect(block).to have_boolean_response false
            end
          end

          context "when the applicant is the beneficiary of a will" do
            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_2WP2_1A")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "GB_INPUT_B_3WP2_1A - applicant has financial interest in his main home" do
          context "when the applicant has no financial interest" do
            before { allow(legal_aid_application).to receive(:own_home?).and_return(false) }

            it "inserts false into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_1A")
              expect(block).to have_boolean_response false
            end
          end

          context "when there is a shared financial interest" do
            before { allow(legal_aid_application).to receive(:own_home?).and_return(true) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_1A")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "POLICE_NOTIFIED block" do
          context "when the are police notified" do
            before { domestic_abuse_summary.update(police_notified: true) }

            it "is true" do
              block = XmlExtractor.call(xml, :global_merits, "POLICE_NOTIFIED")
              expect(block).to have_boolean_response true
            end
          end

          context "when the police are NOT notified" do
            before { domestic_abuse_summary.update(police_notified: false) }

            it "is false" do
              block = XmlExtractor.call(xml, :global_merits, "POLICE_NOTIFIED")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "WARNING_LETTER_SENT" do
          context "when the letter has not been sent" do
            it "generates WARNING_LETTER_SENT block with false value" do
              block = XmlExtractor.call(xml, :global_merits, "WARNING_LETTER_SENT")
              expect(block).to have_boolean_response false
            end

            it "includes correct text in INJ_REASON_NO_WARNING_LETTER block" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_REASON_NO_WARNING_LETTER")
              expect(block).to have_text_response "."
            end
          end

          context "when the letter has been sent" do
            before { domestic_abuse_summary.update(warning_letter_sent: true) }

            it "generates WARNING_LETTER_SENT block with true value" do
              block = XmlExtractor.call(xml, :global_merits, "WARNING_LETTER_SENT")
              expect(block).to have_boolean_response true
            end

            it "does not generate the INJ_REASON_NO_WARNING_LETTER block" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_REASON_NO_WARNING_LETTER")
              expect(block).not_to be_present, "Expected block for attribute INJ_REASON_NO_WARNING_LETTER not to be generated, but was in global_merits"
            end
          end
        end

        describe "INJ_RESPONDENT_CAPACITY" do
          context "when the opponent has capacity" do
            before { parties_mental_capacity.understands_terms_of_court_order = true }

            it "is true" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_RESPONDENT_CAPACITY")
              expect(block).to have_boolean_response true
            end
          end

          context "when the opponent does not have capacity" do
            before { parties_mental_capacity.understands_terms_of_court_order = false }

            it "is false" do
              block = XmlExtractor.call(xml, :global_merits, "INJ_RESPONDENT_CAPACITY")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "GB_INPUT_B_3WP2_1A - Applicant has a financial interest in main home?" do
          context "when the applicant has no financial interest in the main home" do
            before { allow(legal_aid_application).to receive(:own_home).and_return(false) }

            it "inserts false into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_1A")
              expect(block).to have_boolean_response false
            end
          end

          context "when the applicant has a financial interest in the main home" do
            before { allow(legal_aid_application).to receive(:own_home).and_return(true) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_1A")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "attributes hard coded to true" do
          it "hard codes the attributes to true", :aggregate_failures do
            attributes = [
              [:global_means, "APPLICATION_FROM_APPLY"],
              [:global_means, "GB_INPUT_B_38WP3_2SCREEN"],
              [:global_means, "GB_INPUT_B_38WP3_3SCREEN"],
              [:global_means, "GB_DECL_B_38WP3_13A"],
              [:global_means, "LAR_SCOPE_FLAG"],
              [:global_means, "MEANS_EVIDENCE_PROVIDED"],
              [:global_means, "MEANS_SUBMISSION_PG_DISPLAYED"],
              [:global_merits, "APPLICATION_FROM_APPLY"],
              [:global_merits, "CASE_OWNER_STD_FAMILY_MERITS"],
              [:global_merits, "CLIENT_HAS_DV_RISK"],
              [:global_merits, "CLIENT_REQ_SEP_REP"],
              [:global_merits, "DECLARATION_REVOKE_IMP_SUBDP"],
              [:global_merits, "DECLARATION_WILL_BE_SIGNED"],
              [:global_merits, "MERITS_DECLARATION_SCREEN"],
              [:global_merits, "MERITS_EVIDENCE_PROVIDED"],
              [:proceeding_means, "SCOPE_LIMIT_IS_DEFAULT"],
              [:proceeding_merits, "LEAD_PROCEEDING"],
              [:proceeding_merits, "SCOPE_LIMIT_IS_DEFAULT"],
            ]

            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "applicant" do
          describe "DATE_OF_BIRTH" do
            it "inserts applicant's date of birth as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "DATE_OF_BIRTH")
                expect(block).to have_date_response legal_aid_application.applicant.date_of_birth.strftime("%d-%m-%Y")
              end
            end
          end

          describe "FIRST_NAME" do
            it "inserts applicant's first name as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "FIRST_NAME")
                expect(block).to have_text_response legal_aid_application.applicant.first_name
              end
            end
          end

          describe "POST_CODE" do
            it "inserts applicant's postcode as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "POST_CODE")
                expect(block).to have_text_response legal_aid_application.applicant.correspondence_address_for_ccms.postcode
              end
            end
          end

          describe "SURNAME" do
            it "inserts applicant's surname as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "SURNAME")
                expect(block).to have_text_response legal_aid_application.applicant.last_name
              end
            end
          end

          describe "SURNAME_AT_BIRTH" do
            it "inserts applicant's surname at birth as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "SURNAME_AT_BIRTH")
                expect(block).to have_text_response legal_aid_application.applicant.last_name
              end
            end
          end

          describe "CLIENT_AGE" do
            it "inserts applicant's age as a number" do
              block = XmlExtractor.call(xml, :global_merits, "CLIENT_AGE")
              expect(block).to have_number_response legal_aid_application.applicant.age
            end
          end
        end

        describe "DATE_CLIENT_VISITED_FIRM" do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }

          it "inserts today's date as a string" do
            block = XmlExtractor.call(xml, :global_merits, "DATE_CLIENT_VISITED_FIRM")
            expect(block).to have_date_response Time.zone.today.strftime("%d-%m-%Y")
          end
        end

        describe "_SYSTEM_PUI_USERID" do
          it "inserts provider's email address" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "_SYSTEM_PUI_USERID")
              expect(block).to have_text_response legal_aid_application.provider.email
            end
          end
        end

        describe "USER_PROVIDER_FIRM_ID" do
          it "inserts provider's firm id as a number" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "USER_PROVIDER_FIRM_ID")
              expect(block).to have_number_response legal_aid_application.provider.firm.ccms_id
            end
          end
        end

        describe "DATE_ASSESSMENT_STARTED" do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }

          it "inserts today's date as a string" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "DATE_ASSESSMENT_STARTED")
              expect(block).to have_date_response Time.zone.today.strftime("%d-%m-%Y")
            end
          end
        end

        describe "attributes omitted from payload" do
          it "omits the following attributes from the payload" do
            omitted_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
            end
          end
        end

        describe "BAIL_CONDITIONS_SET" do
          context "when bail conditions are set" do
            before { domestic_abuse_summary.bail_conditions_set = true }

            it "is true" do
              block = XmlExtractor.call(xml, :global_merits, "BAIL_CONDITIONS_SET")
              expect(block).to have_boolean_response true
            end
          end

          context "when bail conditions are NOT set" do
            before { domestic_abuse_summary.bail_conditions_set = false }

            it "is false" do
              block = XmlExtractor.call(xml, :global_merits, "BAIL_CONDITIONS_SET")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "Benefit Checker" do
          describe "BEN_DOB" do
            it "inserts applicant's date of birth as a string" do
              block = XmlExtractor.call(xml, :global_means, "BEN_DOB")
              expect(block).to have_date_response legal_aid_application.applicant.date_of_birth.strftime("%d-%m-%Y")
            end
          end

          describe "BEN_NI_NO" do
            it "inserts applicant's national insurance number as a string" do
              block = XmlExtractor.call(xml, :global_means, "BEN_NI_NO")
              expect(block).to have_text_response legal_aid_application.applicant.national_insurance_number
            end
          end

          describe "BEN_SURNAME" do
            it "inserts applicant's surname as a string" do
              block = XmlExtractor.call(xml, :global_means, "BEN_SURNAME")
              expect(block).to have_text_response legal_aid_application.applicant.last_name
            end
          end
        end

        describe "LAR_INFER_B_1WP1_36A" do
          context "when benefit check result is yes" do
            before { legal_aid_application.benefit_check_result = create(:benefit_check_result, :positive) }

            it "is set to true" do
              block = XmlExtractor.call(xml, :global_means, "LAR_INFER_B_1WP1_36A")
              expect(block).to have_boolean_response true
            end
          end

          context "when benefit check result is no" do
            before { legal_aid_application.benefit_check_result = create(:benefit_check_result, :negative) }

            it "is set to false" do
              block = XmlExtractor.call(xml, :global_means, "LAR_INFER_B_1WP1_36A")
              expect(block).to have_boolean_response false
            end
          end

          context "when benefit check is unsuccessfull" do
            before { legal_aid_application.benefit_check_result = nil }

            it "is set to false" do
              block = XmlExtractor.call(xml, :global_means, "LAR_INFER_B_1WP1_36A")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "APP_GRANTED_USING_DP" do
          it "uses the DWP benefit check result" do
            block = XmlExtractor.call(xml, :global_merits, "APP_GRANTED_USING_DP")
            expect(block).to have_boolean_response legal_aid_application.used_delegated_functions?
          end
        end

        describe "APP_AMEND_TYPE" do
          context "when delegated functions are used" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     set_lead_proceeding: :da004,
                     proceeding_count: 2,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider:,
                     office:)
            end
            let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA004" } }

            it "returns SUBDP" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APP_AMEND_TYPE")
                expect(block).to have_text_response "SUBDP"
              end
            end
          end

          context "when delegated functions are not used" do
            it "returns SUB" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "APP_AMEND_TYPE")
                expect(block).to have_text_response "SUB"
              end
            end
          end
        end

        describe "EMERGENCY_FURTHER_INFORMATION" do
          let(:block) { XmlExtractor.call(xml, :global_merits, "EMERGENCY_FURTHER_INFORMATION") }

          context "when delegated functions are used" do
            let(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     set_lead_proceeding: :da004,
                     proceeding_count: 2,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider:,
                     office:)
            end
            let!(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA004" } }
            let(:chances_of_success) do
              create(:chances_of_success, :with_optional_text, proceeding:)
            end

            it "returns hard coded statement" do
              expect(block).to have_text_response "."
            end
          end

          context "when delegated functions are not used" do
            it "EMERGENCY_FURTHER_INFORMATION block is not present" do
              expect(block).not_to be_present
            end
          end
        end

        describe "GB_INPUT_B_15WP2_8A client is owed money" do
          it "returns true when applicant is owed money" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_15WP2_8A")
            expect(block).to have_boolean_response true
          end

          it "returns false when applicant is NOT owed money" do
            allow(legal_aid_application.other_assets_declaration).to receive(:money_owed_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_15WP2_8A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_14WP2_8A vehicle is owned" do
          it "returns true when applicant owns a vehicle" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_14WP2_8A")
            expect(block).to have_boolean_response true
          end

          context "when no vehicle is owned" do
            before { legal_aid_application.update(own_vehicle: false) }

            it "returns false when applicant does NOT own a vehicle" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_14WP2_8A")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "GB_INPUT_B_16WP2_7A client interest in a trust" do
          it "returns true when client has interest in a trust" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_16WP2_7A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client has NO interest in a trust" do
            allow(legal_aid_application.other_assets_declaration).to receive(:trust_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_16WP2_7A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_12WP2_2A client valuable possessions" do
          it "returns true" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_12WP2_2A")
            expect(block).to have_boolean_response true
          end

          it "displays VALPOSSESS_INPUT_T_12WP2_7A" do
            block = XmlExtractor.call(xml, :global_means, "VALPOSSESS_INPUT_T_12WP2_7A")
            expect(block).to have_text_response "Aggregate of valuable possessions"
          end

          it "displays VALPOSSESS_INPUT_C_12WP2_8A" do
            block = XmlExtractor.call(xml, :global_means, "VALPOSSESS_INPUT_C_12WP2_8A")
            expect(block).to have_currency_response legal_aid_application.other_assets_declaration.valuable_items_value
          end

          context "when client has NO valuable possessions" do
            before { allow(legal_aid_application.other_assets_declaration).to receive(:valuable_items_value).and_return(nil) }

            it "returns false" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_12WP2_2A")
              expect(block).to have_boolean_response false
            end

            it "does not display VALPOSSESS_INPUT_T_12WP2_7A or VALPOSSESS_INPUT_C_12WP2_8A" do
              %i[VALPOSSESS_INPUT_T_12WP2_7A VALPOSSESS_INPUT_T_12WP2_8A].each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
              end
            end
          end
        end

        describe "GB_INPUT_B_6WP2_1A client has timeshare" do
          it "returns true when client has timeshare" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_6WP2_1A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client does NOT have timeshare" do
            allow(legal_aid_application.other_assets_declaration).to receive(:timeshare_property_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_6WP2_1A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_5WP2_1A client owns land" do
          it "returns true when client owns land" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP2_1A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client does NOT own land" do
            allow(legal_aid_application.other_assets_declaration).to receive(:land_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP2_1A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_9WP2_1A client investments" do
          let(:ns_val) { 0 }
          let(:plc_shares_val) { 0 }
          let(:peps_val) { 0 }
          let(:policy_val) { 0 }

          before do
            legal_aid_application.savings_amount.update(national_savings: ns_val,
                                                        plc_shares: plc_shares_val,
                                                        peps_unit_trusts_capital_bonds_gov_stocks: peps_val,
                                                        life_assurance_endowment_policy: policy_val)
          end

          context "when there are no investments of any type" do
            it "inserts false into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP2_1A")
              expect(block).to have_boolean_response false
            end
          end

          context "when there are national savings only" do
            let(:policy_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP2_1A")
              expect(block).to have_boolean_response true
            end
          end

          context "when there are life_assurance_policy only" do
            let(:ns_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP2_1A")
              expect(block).to have_boolean_response true
            end
          end

          context "when there are multiple investments" do
            let(:ns_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:plc_shares_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:peps_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:policy_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP2_1A")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "GB_INPUT_B_4WP2_1A Does applicant own additional property?" do
          context "when the applicant owns additional property" do
            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_4WP2_1A")
              expect(block).to have_boolean_response true
            end
          end

          context "when the applicant DOES NOT own additional property" do
            before { allow(legal_aid_application.other_assets_declaration).to receive(:second_home_value).and_return(nil) }

            it "returns false when client does NOT own additiaonl property" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_4WP2_1A")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "GB_INPUT_B_5WP1_18A - does the applicant receive a passported benefit?" do
          context "when no passported benefit is received" do
            before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false) }

            it "inserts false into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_18A")
              expect(block).to have_boolean_response false
            end
          end

          context "when the applicant is receiving a passported benefit" do
            before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true) }

            it "inserts true into the attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_18A")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "GB_INPUT_B_7WP2_1A client bank accounts" do
          it "returns true when client has bank accounts" do
            random_value = rand(1...1_000_000.0).round(2)
            allow(legal_aid_application.savings_amount).to receive_messages(offline_current_accounts: random_value, offline_savings_accounts: random_value)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_7WP2_1A")
            expect(block).to have_boolean_response true
          end

          context "when there are negative values in bank accounts" do
            it "returns false when applicant has negative values in bank accounts" do
              random_negative_value = -rand(1...1_000_000.0).round(2)
              allow(legal_aid_application.savings_amount).to receive_messages(offline_current_accounts: random_negative_value, offline_savings_accounts: random_negative_value)
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_7WP2_1A")
              expect(block).to have_boolean_response false
            end
          end

          context "when there are no bank accounts" do
            it "returns false when applicant does NOT have bank accounts" do
              allow(legal_aid_application.savings_amount).to receive_messages(offline_current_accounts: nil, offline_savings_accounts: nil)
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_7WP2_1A")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "GB_INPUT_B_8WP2_1A" do
          context "when the client is signatory to other bank accounts" do
            it "returns true" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_8WP2_1A")
              expect(block).to have_boolean_response true
            end
          end

          context "when the client is not a signatory to other bank accounts" do
            it "returns false" do
              allow(legal_aid_application.savings_amount).to receive(:other_person_account).and_return(nil)
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_8WP2_1A")
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "GB_INPUT_D_18WP2_1A - application submission date" do
          let(:dummy_date) { Faker::Date.between(from: 20.days.ago, to: Time.zone.today) }

          it "inserts the submission date into the attribute block" do
            allow(legal_aid_application).to receive(:calculation_date).and_return(dummy_date)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_D_18WP2_1A")
            expect(block).to have_date_response dummy_date.strftime("%d-%m-%Y")
          end
        end

        describe "GB_INPUT_B_10WP2_1A client other savings" do
          it "returns true when client has other savings" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_10WP2_1A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client does NOT have other savings" do
            allow(legal_aid_application.savings_amount).to receive(:peps_unit_trusts_capital_bonds_gov_stocks).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_10WP2_1A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_13WP2_7A client other policies" do
          it "returns true when client has other policies" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_13WP2_7A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client does NOT have other policies" do
            allow(legal_aid_application.savings_amount).to receive(:life_assurance_endowment_policy).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_13WP2_7A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_INPUT_B_11WP2_3A client other shares" do
          it "returns true when client has other shares" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_11WP2_3A")
            expect(block).to have_boolean_response true
          end

          it "returns false when client does NOT have other shares" do
            allow(legal_aid_application.savings_amount).to receive(:plc_shares).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_11WP2_3A")
            expect(block).to have_boolean_response false
          end
        end

        describe "GB_DECL_B_38WP3_11A application passported" do
          it "returns true when application is passported" do
            allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true)
            block = XmlExtractor.call(xml, :global_means, "GB_DECL_B_38WP3_11A")
            expect(block).to have_boolean_response true
          end

          it "returns false when application is not passported" do
            allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false)
            block = XmlExtractor.call(xml, :global_means, "GB_DECL_B_38WP3_11A")
            expect(block).to have_boolean_response false
          end
        end

        describe "attributes with specific hard coded values" do
          context "when attributes are hard coded to specific values" do
            it "hard codes country to GBR" do
              block = XmlExtractor.call(xml, :global_means, "COUNTRY")
              expect(block).to have_text_response "GBR"
            end

            it "DEVOLVED_POWERS_CONTRACT_FLAG should be hard coded to Yes - Excluding JR Proceedings" do
              attributes = [
                [:global_means, "DEVOLVED_POWERS_CONTRACT_FLAG"],
                [:global_merits, "DEVOLVED_POWERS_CONTRACT_FLAG"],
              ]
              attributes.each do |entity_attribute_pair|
                entity, attribute = entity_attribute_pair
                block = XmlExtractor.call(xml, entity, attribute)
                expect(block).to have_text_response "Yes - Excluding JR Proceedings"
              end
            end
          end

          it "returns a type of boolean hard coded to false" do
            false_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response false
            end
          end

          it "CASES_FEES_DISTRIBUTED should be hard coded to 1" do
            block = XmlExtractor.call(xml, :global_merits, "CASES_FEES_DISTRIBUTED")
            expect(block).to have_number_response 1
          end

          describe "LEVEL_OF_SERVICE" do
            it "is the service level number from the default level of service" do
              %i[proceeding_merits proceeding_means].each do |entity|
                block = XmlExtractor.call(xml, entity, "LEVEL_OF_SERVICE")
                expect(block).to have_text_response proceeding.substantive_level_of_service.to_s
              end
            end
          end

          describe "PROCEEDING_LEVEL_OF_SERVICE" do
            it "displays the name of the lead proceeding default level of service" do
              block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_LEVEL_OF_SERVICE")
              expect(block).to have_text_response proceeding.substantive_level_of_service_name
            end
          end

          it "CLIENT_INVOLVEMENT_TYPE should be hard coded to A" do
            %i[proceeding_merits proceeding_means].each do |entity|
              block = XmlExtractor.call(xml, entity, "CLIENT_INVOLVEMENT_TYPE")
              expect(block).to have_text_response "A"
            end
          end

          context "when attributes are hard coded to false" do
            it "returns a type of text hard coded to false" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, "COST_LIMIT_CHANGED_FLAG")
                expect(block).to have_text_response "false"
              end
            end
          end

          it "NEW_APPL_OR_AMENDMENT should be hard coded to APPLICATION" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "NEW_APPL_OR_AMENDMENT")
              expect(block).to have_text_response "APPLICATION"
            end
          end

          it "USER_TYPE should be hard coded to EXTERNAL" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "USER_TYPE")
              expect(block).to have_text_response "EXTERNAL"
            end
          end

          it "COUNTRY should be hard coded to GBR" do
            block = XmlExtractor.call(xml, :global_merits, "COUNTRY")
            expect(block).to have_text_response "GBR"
          end

          it "MARITIAL_STATUS should be hard coded to UNKNOWN" do
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

          it "NEW_OR_EXISTING should be hard coded to NEW" do
            %i[proceeding_means proceeding_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "NEW_OR_EXISTING")
              expect(block).to have_text_response "NEW"
            end
          end

          it "POA_OR_BILL_FLAG should be hard coded to N/A" do
            block = XmlExtractor.call(xml, :global_means, "POA_OR_BILL_FLAG")
            expect(block).to have_text_response "N/A"
          end

          it "MERITS_ROUTING should be hard coded to SFM" do
            block = XmlExtractor.call(xml, :global_merits, "MERITS_ROUTING")
            expect(block).to have_text_response "SFM"
          end

          it "IS_PASSPORTED should be hard coded to YES" do
            block = XmlExtractor.call(xml, :global_means, "IS_PASSPORTED")
            expect(block).to have_text_response "YES"
          end

          it "returns a hard coded response with the correct notification" do
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

        describe "legal framework attributes" do
          it "populates REQ_COST_LIMITATION" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "REQ_COST_LIMITATION")
              expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
            end
          end

          it "populates APP_IS_FAMILY" do
            block = XmlExtractor.call(xml, :global_merits, "APP_IS_FAMILY")
            expect(block).to have_boolean_response(proceeding.category_of_law == "Family")
          end

          it "populates CAT_OF_LAW_DESCRIPTION" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_DESCRIPTION")
            expect(block).to have_text_response proceeding.category_of_law
          end

          it "populates CAT_OF_LAW_HIGH_LEVEL" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_HIGH_LEVEL")
            expect(block).to have_text_response proceeding.category_of_law
          end

          it "populates CAT_OF_LAW_MEANING" do
            block = XmlExtractor.call(xml, :global_merits, "CAT_OF_LAW_MEANING")
            expect(block).to have_text_response proceeding.meaning
          end

          it "populates CATEGORY_OF_LAW" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "CATEGORY_OF_LAW")
              expect(block).to have_text_response proceeding.category_law_code
            end
          end

          it "populates DEFAULT_COST_LIMITATION_MERITS" do
            block = XmlExtractor.call(xml, :global_merits, "DEFAULT_COST_LIMITATION_MERITS")
            expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
          end

          it "populates DEFAULT_COST_LIMITATION" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "DEFAULT_COST_LIMITATION")
              expect(block).to have_currency_response sprintf("%<value>.2f", value: legal_aid_application.lead_proceeding.substantive_cost_limitation)
            end
          end

          it "populates MATTER_TYPE" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "MATTER_TYPE")
              expect(block).to have_text_response proceeding.ccms_matter_code
            end
          end

          it "populates PROCEEDING_NAME" do
            block = XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_NAME")
            expect(block).to have_text_response proceeding.ccms_code
          end
        end

        describe "SUBSTANTIVE_APP populates correctly" do
          let(:block) { XmlExtractor.call(xml, :global_merits, "SUBSTANTIVE_APP") }

          context "when the application is substantive" do
            it "returns true" do
              expect(block).to have_boolean_response true
            end
          end

          context "when the application is delegated_functions" do
            let!(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     set_lead_proceeding: :da004,
                     explicit_proceedings: [:da004],
                     populate_vehicle: true,
                     provider:,
                     office:)
            end
            let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA004" } }
            let(:chances_of_success) do
              create(:chances_of_success, success_prospect:, success_prospect_details: "details", proceeding:)
            end

            it "returns false" do
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "PROCEEDING_APPLICATION_TYPE populates correctly" do
          let(:block) { XmlExtractor.call(xml, :proceeding_merits, "PROCEEDING_APPLICATION_TYPE") }

          context "when the application is substantive" do
            it "returns Substantive" do
              expect(block).to have_text_response "Substantive"
            end
          end

          context "when the application has used delegated functions" do
            let!(:legal_aid_application) do
              create(:legal_aid_application,
                     :with_proceedings,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     set_lead_proceeding: :da004,
                     explicit_proceedings: [:da004],
                     populate_vehicle: true,
                     with_bank_accounts: 1,
                     provider:,
                     office:)
            end
            let!(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA004" } }
            let(:chances_of_success) do
              create(:chances_of_success, success_prospect:, success_prospect_details: "details", proceeding:)
            end

            it "returns Both" do
              expect(block).to have_text_response "Both"
            end
          end
        end

        describe "OPPONENT_OTHER_PARTIES" do
          let(:legal_aid_application) do
            create(
              :legal_aid_application,
              :with_proceedings,
              :with_everything,
              :with_applicant_and_address,
              :with_positive_benefit_check_result,
              set_lead_proceeding: :da001,
              populate_vehicle: true,
              with_bank_accounts: 2,
              provider:,
              office:,
            ).tap do |laa|
              laa.opponents.destroy_all
            end
          end

          before { opponent }

          context "with means entity" do
            let(:entity) { :opponent_means }

            context "with opponent individual" do
              let(:opponent) { create(:opponent, :for_individual, legal_aid_application:, first_name: "Billy", last_name: "Bob") }

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "OPPONENT_88000001",
                    OTHER_PARTY_NAME: "Billy Bob",
                    OTHER_PARTY_TYPE: "PERSON",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "UNKNOWN",
                  )
              end
            end

            context "with opponent existing organisation" do
              let(:opponent) do
                create(
                  :opponent,
                  :for_organisation,
                  organisation_name: "Babergh Council",
                  organisation_ccms_type_code: "LA",
                  organisation_ccms_type_text: "Local Authority",
                  legal_aid_application:,
                  ccms_opponent_id: 222_222,
                  exists_in_ccms: true,
                )
              end

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "222222",
                    OTHER_PARTY_NAME: "Babergh Council",
                    OTHER_PARTY_TYPE: "ORGANISATION",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "NONE",
                  )
              end
            end

            context "with opponent new organisation" do
              let(:opponent) do
                create(
                  :opponent,
                  :for_organisation,
                  organisation_name: "Foobar Council",
                  organisation_ccms_type_code: "LA",
                  organisation_ccms_type_text: "Local Authority",
                  legal_aid_application:,
                  exists_in_ccms: false,
                )
              end

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "OPPONENT_88000001",
                    OTHER_PARTY_NAME: "Foobar Council",
                    OTHER_PARTY_TYPE: "ORGANISATION",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "NONE",
                  )
              end
            end
          end

          context "with merits entity" do
            let(:entity) { :opponent_merits }

            context "with opponent individual" do
              let(:opponent) { create(:opponent, :for_individual, legal_aid_application:, first_name: "Billy", last_name: "Bob") }

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "OPPONENT_88000001",
                    OTHER_PARTY_NAME: "Billy Bob",
                    OTHER_PARTY_NAME_MERITS: "Billy Bob",
                    OTHER_PARTY_TYPE: "PERSON",
                    OTHER_PARTY_ORG: "false",
                    OTHER_PARTY_PERSON: "true",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "UNKNOWN",
                    RELATIONSHIP_CASE_OPPONENT: "true",
                    OPP_RELATIONSHIP_TO_CASE: "Opponent",
                    OPP_RELATIONSHIP_TO_CLIENT: "Unknown",
                    PARTY_IS_A_CHILD: "false",
                    RELATIONSHIP_CHILD: "false",
                    RELATIONSHIP_CASE_CHILD: "false",
                  )
              end

              it "excludes OPPONENT_DOB" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB not to be generated, but was \n #{block}"
              end

              it "excludes OPPONENT_DOB_MERITS" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB_MERITS")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB_MERITS not to be generated, but was \n #{block}"
              end
            end

            context "with opponent existing organisation" do
              let(:opponent) do
                create(
                  :opponent,
                  :for_organisation,
                  organisation_name: "Babergh Council",
                  organisation_ccms_type_code: "LA",
                  organisation_ccms_type_text: "Local Authority",
                  legal_aid_application:,
                  ccms_opponent_id: 222_222,
                  exists_in_ccms: true,
                )
              end

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "222222",
                    OTHER_PARTY_NAME: "Babergh Council",
                    OTHER_PARTY_NAME_MERITS: "Babergh Council",
                    OTHER_PARTY_TYPE: "ORGANISATION",
                    OTHER_PARTY_ORG: "true",
                    OTHER_PARTY_PERSON: "false",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "NONE",
                    RELATIONSHIP_CASE_OPPONENT: "true",
                    OPP_RELATIONSHIP_TO_CASE: "Opponent",
                    OPP_RELATIONSHIP_TO_CLIENT: "None",
                    PARTY_IS_A_CHILD: "false",
                    RELATIONSHIP_CHILD: "false",
                    RELATIONSHIP_CASE_CHILD: "false",
                  )
              end

              it "excludes OPPONENT_DOB" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB not to be generated, but was \n #{block}"
              end

              it "excludes OPPONENT_DOB_MERITS" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB_MERITS")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB_MERITS not to be generated, but was \n #{block}"
              end
            end

            context "with opponent new organisation" do
              let(:opponent) do
                create(
                  :opponent,
                  :for_organisation,
                  organisation_name: "Foobar Council",
                  organisation_ccms_type_code: "LA",
                  organisation_ccms_type_text: "Local Authority",
                  legal_aid_application:,
                  exists_in_ccms: false,
                )
              end

              it "has expected payload attributes" do
                block = XmlExtractor.call(xml, entity)

                expect(block)
                  .to have_xml_attributes(
                    OTHER_PARTY_ID: "OPPONENT_88000001",
                    OTHER_PARTY_NAME: "Foobar Council",
                    OTHER_PARTY_NAME_MERITS: "Foobar Council",
                    OTHER_PARTY_TYPE: "ORGANISATION",
                    OTHER_PARTY_ORG: "true",
                    OTHER_PARTY_PERSON: "false",
                    RELATIONSHIP_TO_CASE: "OPP",
                    RELATIONSHIP_TO_CLIENT: "NONE",
                    RELATIONSHIP_CASE_OPPONENT: "true",
                    OPP_RELATIONSHIP_TO_CASE: "Opponent",
                    OPP_RELATIONSHIP_TO_CLIENT: "None",
                    PARTY_IS_A_CHILD: "false",
                    RELATIONSHIP_CHILD: "false",
                    RELATIONSHIP_CASE_CHILD: "false",
                  )
              end

              it "excludes OPPONENT_DOB" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB not to be generated, but was \n #{block}"
              end

              it "excludes OPPONENT_DOB_MERITS" do
                block = XmlExtractor.call(xml, entity, "OPPONENT_DOB_MERITS")
                expect(block).not_to be_present, "Expected block for attribute OPPONENT_DOB_MERITS not to be generated, but was \n #{block}"
              end
            end
          end
        end

        describe "APPLY_CASE_MEANS_REVIEW in global means and global merits" do
          let(:determiner) { instance_double ManualReviewDeterminer }

          before { allow(ManualReviewDeterminer).to receive(:new).and_return(determiner) }

          context "when Manual review required" do
            it "set the attribute to false" do
              allow(determiner).to receive(:manual_review_required?).and_return(true)
              block = XmlExtractor.call(xml, :global_means, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response false
              block = XmlExtractor.call(xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response false
            end
          end

          context "when Manual review is not required" do
            it "sets the attribute to true" do
              allow(determiner).to receive(:manual_review_required?).and_return(false)
              block = XmlExtractor.call(xml, :global_means, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response true
              block = XmlExtractor.call(xml, :global_merits, "APPLY_CASE_MEANS_REVIEW")
              expect(block).to have_boolean_response true
            end
          end
        end

        describe "Partner values" do
          context "when the applicant has a partner" do
            before do
              create(:partner, first_name: "Rupert", last_name: "Giles", date_of_birth: Date.new(1955, 4, 11), legal_aid_application:)
              legal_aid_application.applicant.update!(has_partner: true)
            end

            describe "GB_INPUT_B_5WP1_3A - Client: The client has a partner?" do
              it "returns true" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_3A")
                expect(block).to have_boolean_response true
              end
            end

            describe "GB_INPUT_T_5WP1_5A - Partner: First name" do
              it "is populated with the partners details" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_5A")
                expect(block).to have_text_response "Rupert"
              end
            end

            describe "GB_INPUT_T_5WP1_6A - Partner: Last name" do
              it "is populated with the partners details" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_6A")
                expect(block).to have_text_response "Giles"
              end
            end

            describe "GB_INPUT_D_5WP1_8A - Partner: DOB" do
              it "is populated with the partners details" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_D_5WP1_8A")
                expect(block).to have_date_response "11-04-1955"
              end
            end
          end

          context "when the applicant has a partner with a contrary interest" do
            before do
              legal_aid_application.applicant.update(has_partner: true, partner_has_contrary_interest: true)
            end

            describe "GB_INPUT_B_5WP1_3A - Client: The client has a partner?" do
              it "returns false" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_3A")
                expect(block).to have_boolean_response false
              end
            end

            describe "GB_INPUT_T_5WP1_5A - Partner: First name" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_5A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_5A not to be generated, but was \n #{block}"
              end
            end

            describe "GB_INPUT_T_5WP1_6A - Partner: Surname" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_6A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_6A not to be generated, but was \n #{block}"
              end
            end

            describe "GB_INPUT_T_5WP1_8A - Partner: DOB" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_8A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_8A not to be generated, but was \n #{block}"
              end
            end
          end

          context "when the applicant does not have a partner" do
            describe "GB_INPUT_B_5WP1_3A - Client: The client has a partner?" do
              it "returns false" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_5WP1_3A")
                expect(block).to have_boolean_response false
              end
            end

            describe "GB_INPUT_T_5WP1_5A - Partner: First name" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_5A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_5A not to be generated, but was \n #{block}"
              end
            end

            describe "GB_INPUT_T_5WP1_6A - Partner: Surname" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_6A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_6A not to be generated, but was \n #{block}"
              end
            end

            describe "GB_INPUT_T_5WP1_8A - Partner: DOB" do
              it "is not returned" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_T_5WP1_8A")
                expect(block).not_to be_present, "Expected block for attribute GB_INPUT_T_5WP1_8A not to be generated, but was \n #{block}"
              end
            end
          end
        end
      end

      def omitted_attributes
        load_ccms_attribute_array("passported_omitted.csv")
      end

      def false_attributes
        load_ccms_attribute_array("passported_false.csv")
      end
    end
  end
end
