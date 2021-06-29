require 'rails_helper'

module CCMS
  module Requestors # rubocop:disable Metrics/ModuleLength
    RSpec.describe CaseAddRequestor do
      context 'XML request' do
        let(:expected_tx_id) { '201904011604570390059770666' }
        let(:firm) { create :firm, name: 'Firm1' }
        let(:office) { create :office, firm: firm }
        let(:provider) do
          create :provider,
                 firm: firm,
                 selected_office: office,
                 username: 4_953_649
        end

        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_proceeding_types,
                 :with_everything,
                 :with_applicant_and_address,
                 :with_positive_benefit_check_result,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider: provider,
                 office: office
        end

        let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
        let(:opponent) { legal_aid_application.opponent }
        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let!(:success_prospect) { :likely }
        let!(:chances_of_success) do
          create :chances_of_success, success_prospect: success_prospect, success_prospect_details: 'details', application_proceeding_type: application_proceeding_type
        end

        # enable this context if you need to create a file of the payload for manual inspection
        # context 'saving to a temporary file', skip: 'Not needed for testing - but useful if you want to save the payload to a file' do
        context 'save to a temporary file' do
          it 'creates a file' do
            filename = Rails.root.join('tmp/generated_ccms_payload.xml')
            File.open(filename, 'w') { |f| f.puts xml }
            expect(File.exist?(filename)).to be true
          end
        end

        context 'DevolvedPowersDate' do
          context 'on a Substantive case' do
            it 'is omitted' do
              block = XmlExtractor.call(xml, :devolved_powers_date)
              expect(block).not_to be_present, "Expected block for attribute DevolvedPowersDate not to be generated, but was \n #{block}"
            end
          end

          context 'on a Delegated Functions case' do
            before do
              legal_aid_application.application_proceeding_types.each do |apt|
                apt.update!(used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it 'is populated with the delegated functions date' do
              block = XmlExtractor.call(xml, :devolved_powers_date)
              expect(block.children.text).to eq legal_aid_application.used_delegated_functions_on.to_s(:ccms_date)
            end
          end
        end

        context 'PASSPORTED_NINO' do
          let(:applicant) { legal_aid_application.applicant }
          it 'generates PASSPORTED NINO in global merits' do
            block = XmlExtractor.call(xml, :global_means, 'PASSPORTED_NINO')
            expect(block).to have_text_response applicant.national_insurance_number
            expect(block).to be_user_defined
          end
        end

        context 'GB_INFER_T_6WP1_66A' do
          it 'generates GB_INFER_T_6WP1_66A in global merits' do
            block = XmlExtractor.call(xml, :global_merits, 'GB_INFER_T_6WP1_66A')
            expect(block).to have_text_response 'CLIENT'
            expect(block).not_to be_user_defined
          end
        end

        context 'CLIENT_ELIGIBILITY and PUI_CLIENT_ELIGIBILITY' do
          context 'eligible' do
            let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
            it 'returns In Scope' do
              block = XmlExtractor.call(xml, :global_means, 'CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'In Scope'
              block = XmlExtractor.call(xml, :global_means, 'PUI_CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'In Scope'
            end
          end

          context 'not_eligible' do
            let!(:cfe_result) { create :cfe_v3_result, :not_eligible, submission: cfe_submission }
            it 'returns Out Of Scope' do
              block = XmlExtractor.call(xml, :global_means, 'CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'Out Of Scope'
              block = XmlExtractor.call(xml, :global_means, 'PUI_CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'Out Of Scope'
            end
          end

          context 'contribution_required' do
            let!(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission }
            it 'returns In Scope' do
              block = XmlExtractor.call(xml, :global_means, 'CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'In Scope'
              block = XmlExtractor.call(xml, :global_means, 'PUI_CLIENT_ELIGIBILITY')
              expect(block).to have_text_response 'In Scope'
            end
          end

          context 'invalid response' do
            let!(:cfe_result) do
              create(:cfe_v3_result,
                     :with_unknown_result,
                     submission: cfe_submission)
            end

            it 'raises' do
              expect { xml }.to raise_error RuntimeError, 'Unexpected assessment result: unknown'
            end
          end
        end

        context 'INCOME_CONT' do
          it 'always returns zero' do
            block = XmlExtractor.call(xml, :global_means, 'INCOME_CONT')
            expect(block).to have_currency_response '0.00'
          end
        end

        context 'CAP_CONT and similar attributes' do
          let(:attributes) { %w[PUI_CLIENT_CAP_CONT CAP_CONT OUT_CAP_CONT] }
          context 'eligble' do
            let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
            it 'returns zero' do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response '0.00'
              end
            end
          end

          context 'not eligble' do
            let!(:cfe_result) { create :cfe_v3_result, :not_eligible, submission: cfe_submission }
            it 'returns zero' do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response '0.00'
              end
              block = XmlExtractor.call(xml, :global_means, 'PUI_CLIENT_CAP_CONT')
              expect(block).to have_currency_response '0.00'
            end
          end

          context 'contribution_required' do
            let!(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission }
            it 'returns the capital contribution' do
              attributes.each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).to have_currency_response '465.66'
              end
            end
          end
        end

        context 'valuable possessions entity' do
          context 'valuable possessions present' do
            it 'creates the entity' do
              entity_block = XmlExtractor.call(xml, :valuable_possessions_entity)
              expect(entity_block).to be_present
            end
          end

          context 'no valuable possessions present' do
            before { legal_aid_application.other_assets_declaration.valuable_items_value = nil }

            it 'does not generate the bank accounts entity' do
              block = XmlExtractor.call(xml, :valuable_possessions_entity)
              expect(block).not_to be_present, "Expected block for valuable possessions entity not to be generated, but was \n #{block}"
            end

            it 'assigns the sequence number of 1 to the next entity ' do
              bank_accounts_entity = XmlExtractor.call(xml, :bank_accounts_entity)
              doc = Nokogiri::XML(bank_accounts_entity.to_s)
              bank_accounts_sequence = doc.xpath('//SequenceNumber').text.to_i
              expect(bank_accounts_sequence).to eq 1
            end
          end
        end

        context 'bank accounts entity' do
          context 'bank accounts present' do
            it 'creates the entity' do
              entity_block = XmlExtractor.call(xml, :bank_accounts_entity)
              expect(entity_block).to be_present
            end
          end

          context 'no bank accounts present' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     vehicle: nil,
                     office: office
            end

            it 'does not generate the bank accounts entity' do
              block = XmlExtractor.call(xml, :bank_accounts_entity)
              expect(block).not_to be_present, "Expected block for bank accounts entity not to be generated, but was \n #{block}"
            end

            it 'assigns the sequence number to the next entity one higher than that for valuable possessions' do
              valuable_possessions_entity = XmlExtractor.call(xml, :valuable_possessions_entity)
              doc = Nokogiri::XML(valuable_possessions_entity.to_s)
              valuable_possessions_sequence = doc.xpath('//SequenceNumber').text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath('//SequenceNumber').text.to_i
              expect(means_proceeding_sequence).to eq valuable_possessions_sequence + 1
            end
          end
        end

        context 'car and vehicle entity' do
          context 'car and vehicle present' do
            it 'creates the entity' do
              entity_block = XmlExtractor.call(xml, :vehicle_entity)
              expect(entity_block).to be_present
            end

            context 'CARANDVEH_INPUT_B_14WP2_28A - In regular use' do
              it 'is flase' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_B_14WP2_28A')
                expect(block).to have_boolean_response legal_aid_application.vehicle.used_regularly?
              end
            end

            context 'CARANDVEH_INPUT_D_14WP2_27A - Date of purchase' do
              it 'is populated with the purchase date' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_D_14WP2_27A')
                expect(block).to have_date_response legal_aid_application.vehicle.purchased_on.strftime('%d-%m-%Y')
              end
            end

            context 'CARANDVEH_INPUT_T_14WP2_20A - Make of vehicle' do
              it "is populated with 'Make: unspecified'" do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_T_14WP2_20A')
                expect(block).to have_text_response('Make: unspecified')
              end
            end

            context 'CARANDVEH_INPUT_T_14WP2_21A - Model of vehicle' do
              it "is populated with 'Model: unspecified'" do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_T_14WP2_21A')
                expect(block).to have_text_response('Model: unspecified')
              end
            end

            context 'CARANDVEH_INPUT_T_14WP2_22A - Registration number' do
              it "is populated with 'Registration number: unspecified'" do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_T_14WP2_22A')
                expect(block).to have_text_response('Registration number: unspecified')
              end
            end

            context 'CARANDVEH_INPUT_C_14WP2_24A - Purchase price' do
              it 'is populated with zero' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_C_14WP2_24A')
                expect(block).to have_currency_response('0.00')
              end
            end

            context 'CARANDVEH_INPUT_C_14WP2_25A - Current market value' do
              it 'is populated with the estimated value' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_C_14WP2_25A')
                expect(block).to have_currency_response(format('%<value>.2f', value: legal_aid_application.vehicle.estimated_value))
              end
            end

            context 'CARANDVEH_INPUT_C_14WP2_26A - Value of loan outstanding' do
              it 'is populated with the payment remaining' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_C_14WP2_26A')
                expect(block).to have_currency_response(format('%<value>.2f', value: legal_aid_application.vehicle.payment_remaining))
              end
            end
          end

          context 'no car and vehicle present' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     with_bank_accounts: 2,
                     vehicle: nil,
                     office: office
            end

            it 'does not generate the vehicle entity' do
              block = XmlExtractor.call(xml, :vehicle_entity)
              expect(block).not_to be_present, "Expected block for vehicle entity not to be generated, but was \n #{block}"
            end

            it 'assigns the sequence number to the next entity one higher than that for bank accounts' do
              bank_acount_entity = XmlExtractor.call(xml, :bank_accounts_entity)
              doc = Nokogiri::XML(bank_acount_entity.to_s)
              bank_account_sequence = doc.xpath('//SequenceNumber').text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath('//SequenceNumber').text.to_i
              expect(means_proceeding_sequence).to eq bank_account_sequence + 1
            end
          end
        end

        context 'wage slips entity' do
          context 'no wage slips present' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     office: office
            end

            it 'does not generate the wage slips entity' do
              block = XmlExtractor.call(xml, :wage_slip_entity)
              expect(block).not_to be_present, "Expected block for wage slips entity not to be generated, but was \n #{block}"
            end

            it 'assigns the sequence number to the next entity one higher than that for vehicles' do
              vehicle_entity = XmlExtractor.call(xml, :vehicle_sequence_entity)
              doc = Nokogiri::XML(vehicle_entity.to_s)
              vehicle_sequence = doc.xpath('//SequenceNumber').text.to_i

              means_proceeding_entity = XmlExtractor.call(xml, :means_proceeding_entity)
              doc = Nokogiri::XML(means_proceeding_entity.to_s)
              means_proceeding_sequence = doc.xpath('//SequenceNumber').text.to_i
              expect(means_proceeding_sequence).to eq vehicle_sequence + 1
            end
          end
        end

        context 'employment entity' do
          context 'no employment details present' do
            it 'does not generate the employment entity' do
              block = XmlExtractor.call(xml, :employment_entity)
              expect(block).not_to be_present, "Expected block for wage slips entity not to be generated, but was \n #{block}"
            end
          end
        end

        context 'ProceedingCaseId' do
          context 'ProceedingCaseId section' do
            it 'has a p number' do
              block = XmlExtractor.call(xml, :proceeding_case_id)
              expect(block.text).to eq application_proceeding_type.proceeding_case_p_num
            end
          end

          context 'in merits assessment block' do
            it 'has a p number' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'PROCEEDING_ID')
              expect(block).to have_text_response(application_proceeding_type.proceeding_case_p_num)
            end
          end

          context 'in means assessment block' do
            it 'has a p number' do
              block = XmlExtractor.call(xml, :proceeding, 'PROCEEDING_ID')
              expect(block).to have_text_response(application_proceeding_type.proceeding_case_p_num)
            end
          end
        end

        context 'APPLICATION_CASE_REF' do
          it 'inserts the case reference from the submission record the global means sections' do
            block = XmlExtractor.call(xml, :global_means, 'APPLICATION_CASE_REF')
            expect(block).to have_text_response submission.case_ccms_reference
          end

          it 'inserts the case reference from the submission record the global merits sections' do
            block = XmlExtractor.call(xml, :global_merits, 'APPLICATION_CASE_REF')
            expect(block).to have_text_response ccms_reference
          end
        end

        context 'FAMILY_PROSPECTS_OF_SUCCESS' do
          context 'likely success prospect' do
            it 'returns the ccms equivalent prospect of success for likely' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'FAMILY_PROSPECTS_OF_SUCCESS')
              expect(block).to have_text_response 'Good'
            end
          end

          context 'marginal success prospect' do
            let(:success_prospect) { 'marginal' }

            it 'returns the ccms equivalent prospect of success for marginal' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'FAMILY_PROSPECTS_OF_SUCCESS')
              expect(block).to have_text_response 'Marginal'
            end
          end

          context 'not_known success prospect' do
            let(:success_prospect) { 'not_known' }
            it 'returns the ccms equivalent prospect of success for not_known' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'FAMILY_PROSPECTS_OF_SUCCESS')
              expect(block).to have_text_response 'Uncertain'
            end
          end

          context 'poor success prospect' do
            let(:success_prospect) { 'poor' }
            it 'returns the ccms equivalent prospect of success for poor' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'FAMILY_PROSPECTS_OF_SUCCESS')
              expect(block).to have_text_response 'Poor'
            end
          end

          context 'borderline success prospect' do
            let(:success_prospect) { 'borderline' }
            it 'returns the ccms equivalent prospect of success for borderline' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'FAMILY_PROSPECTS_OF_SUCCESS')
              expect(block).to have_text_response 'Borderline'
            end
          end
        end

        context 'DELEGATED_FUNCTIONS_DATE blocks' do
          context 'delegated functions used' do
            before do
              legal_aid_application.application_proceeding_types.each do |apt|
                apt.update!(used_delegated_functions_on: Time.zone.today, used_delegated_functions_reported_on: Time.zone.today)
              end
            end

            it 'generates the delegated functions block in the means assessment section' do
              block = XmlExtractor.call(xml, :global_means, 'DELEGATED_FUNCTIONS_DATE')
              expect(block).to have_date_response(Time.zone.today.strftime('%d-%m-%Y'))
            end

            it 'generates the delegated functions block in the merits assessment section' do
              block = XmlExtractor.call(xml, :global_merits, 'DELEGATED_FUNCTIONS_DATE')
              expect(block).to have_date_response(Time.zone.today.strftime('%d-%m-%Y'))
            end
          end

          context 'delegated functions not used' do
            it 'does not generate the delegated functions block in the means assessment section' do
              block = XmlExtractor.call(xml, :global_means, 'DELEGATED_FUNCTIONS_DATE')
              expect(block).not_to be_present
            end

            it 'does not generates the delegated functions block in the merits assessment section' do
              block = XmlExtractor.call(xml, :global_merits, 'DELEGATED_FUNCTIONS_DATE')
              expect(block).not_to be_present
            end
          end
        end

        context 'EMERGENCY_FC_CRITERIA' do
          it 'inserts emergency_fc criteria as hard coded string' do
            block = XmlExtractor.call(xml, :global_merits, 'EMERGENCY_FC_CRITERIA')
            expect(block).to have_text_response '.'
          end
        end

        context 'URGENT_HEARING_DATE' do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }
          it 'inserts ccms submission date as string' do
            block = XmlExtractor.call(xml, :global_merits, 'URGENT_HEARING_DATE')
            expect(block).to have_date_response legal_aid_application.calculation_date.strftime('%d-%m-%Y')
          end
        end

        context 'APPLICATION_CASE_REF' do
          it 'inserts the ccms case reference from the submission into the attribute block' do
            block = XmlExtractor.call(xml, :global_means, 'APPLICATION_CASE_REF')
            expect(block).to have_text_response ccms_reference
          end
        end

        context 'GB_INPUT_B_2WP2_1A  - Applicant is a beneficiary of a will?' do
          context 'not a beneficiary' do
            before { legal_aid_application.other_assets_declaration = create :other_assets_declaration, :all_nil }
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_2WP2_1A')
              expect(block).to have_boolean_response false
            end
          end

          context 'is a beneficiary' do
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_2WP2_1A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'GB_INPUT_B_3WP2_1A - applicant has financial interest in his main home' do
          context 'no financial interest' do
            before { expect(legal_aid_application).to receive(:own_home?).and_return(false) }
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_3WP2_1A')
              expect(block).to have_boolean_response false
            end
          end

          context 'a shared finanical interest' do
            before { expect(legal_aid_application).to receive(:own_home?).and_return(true) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_3WP2_1A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'POLICE_NOTIFIED block' do
          context 'police notified' do
            before { opponent.update(police_notified: true) }
            it 'is true' do
              block = XmlExtractor.call(xml, :global_merits, 'POLICE_NOTIFIED')
              expect(block).to have_boolean_response true
            end
          end

          context 'police NOT notified' do
            before { opponent.update(police_notified: false) }
            it 'is false' do
              block = XmlExtractor.call(xml, :global_merits, 'POLICE_NOTIFIED')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'WARNING_LETTER_SENT' do
          context 'letter has not been sent' do
            it 'generates WARNING_LETTER_SENT block with false value' do
              block = XmlExtractor.call(xml, :global_merits, 'WARNING_LETTER_SENT')
              expect(block).to have_boolean_response false
            end

            it 'includes correct text in INJ_REASON_NO_WARNING_LETTER block' do
              block = XmlExtractor.call(xml, :global_merits, 'INJ_REASON_NO_WARNING_LETTER')
              expect(block).to have_text_response '.'
            end
          end

          context 'letter has been sent' do
            before { opponent.update(warning_letter_sent: true) }
            it 'generates WARNING_LETTER_SENT block with true value' do
              block = XmlExtractor.call(xml, :global_merits, 'WARNING_LETTER_SENT')
              expect(block).to have_boolean_response true
            end

            it 'does not generate the INJ_REASON_NO_WARNING_LETTER block' do
              block = XmlExtractor.call(xml, :global_merits, 'INJ_REASON_NO_WARNING_LETTER')
              expect(block).not_to be_present, 'Expected block for attribute INJ_REASON_NO_WARNING_LETTER not to be generated, but was in global_merits'
            end
          end
        end

        context 'INJ_RESPONDENT_CAPACITY' do
          context 'opponent has capacity' do
            before { opponent.understands_terms_of_court_order = true }
            it 'is true' do
              block = XmlExtractor.call(xml, :global_merits, 'INJ_RESPONDENT_CAPACITY')
              expect(block).to have_boolean_response true
            end
          end

          context 'opponent does not have capacity' do
            before { opponent.understands_terms_of_court_order = false }
            it 'is false' do
              block = XmlExtractor.call(xml, :global_merits, 'INJ_RESPONDENT_CAPACITY')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'GB_INPUT_B_2WP2_1A - Applicant is a beneficiary of a will?' do
          context 'not a beneficiary' do
            before { legal_aid_application.other_assets_declaration.update(inherited_assets_value: 0) }
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_2WP2_1A')
              expect(block).to have_boolean_response false
            end
          end

          context 'is a beneficiary' do
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_2WP2_1A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'GB_INPUT_B_3WP2_1A - Applicant has a financial interest in main home?' do
          context 'no interest' do
            before { expect(legal_aid_application).to receive(:own_home).and_return(false) }
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_3WP2_1A')
              expect(block).to have_boolean_response false
            end
          end
          context 'has an interest' do
            before { expect(legal_aid_application).to receive(:own_home).and_return(true) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_3WP2_1A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'attributes hard coded to true' do
          it 'should be hard coded to true' do
            attributes = [
              [:global_means, 'APPLICATION_FROM_APPLY'],
              [:global_means, 'GB_INPUT_B_38WP3_2SCREEN'],
              [:global_means, 'GB_INPUT_B_38WP3_3SCREEN'],
              [:global_means, 'GB_DECL_B_38WP3_13A'],
              [:global_means, 'LAR_SCOPE_FLAG'],
              [:global_means, 'MEANS_EVIDENCE_PROVIDED'],
              [:global_merits, 'APPLICATION_FROM_APPLY'],
              [:global_merits, 'CLIENT_HAS_DV_RISK'],
              [:global_merits, 'CLIENT_REQ_SEP_REP'],
              [:global_merits, 'DECLARATION_REVOKE_IMP_SUBDP'],
              [:global_merits, 'DECLARATION_WILL_BE_SIGNED'],
              [:global_merits, 'MERITS_DECLARATION_SCREEN'],
              [:global_merits, 'MERITS_EVIDENCE_PROVIDED'],
              [:proceeding, 'SCOPE_LIMIT_IS_DEFAULT'],
              [:proceeding_merits, 'LEAD_PROCEEDING'],
              [:proceeding_merits, 'SCOPE_LIMIT_IS_DEFAULT'],
              [:global_means, 'APPLICATION_FROM_APPLY'],
              [:global_means, 'APPLICATION_FROM_APPLY'],
              [:global_means, 'MEANS_SUBMISSION_PG_DISPLAYED'],
              [:global_merits, 'CASE_OWNER_STD_FAMILY_MERITS']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'applicant' do
          context 'DATE_OF_BIRTH' do
            it "inserts applicant's date of birth as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'DATE_OF_BIRTH')
                expect(block).to have_date_response legal_aid_application.applicant.date_of_birth.strftime('%d-%m-%Y')
              end
            end
          end
          context 'FIRST_NAME' do
            it "inserts applicant's first name as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'FIRST_NAME')
                expect(block).to have_text_response legal_aid_application.applicant.first_name
              end
            end
          end
          context 'POST_CODE' do
            it "inserts applicant's postcode as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'POST_CODE')
                expect(block).to have_text_response legal_aid_application.applicant.address.postcode
              end
            end
          end
          context 'SURNAME' do
            it "inserts applicant's surname as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'SURNAME')
                expect(block).to have_text_response legal_aid_application.applicant.last_name
              end
            end
          end
          context 'SURNAME_AT_BIRTH' do
            it "inserts applicant's surname at birth as a string" do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'SURNAME_AT_BIRTH')
                expect(block).to have_text_response legal_aid_application.applicant.last_name
              end
            end
          end
          context 'CLIENT_AGE' do
            it "inserts applicant's age as a number" do
              block = XmlExtractor.call(xml, :global_merits, 'CLIENT_AGE')
              expect(block).to have_number_response legal_aid_application.applicant.age
            end
          end
        end

        context 'DATE_CLIENT_VISITED_FIRM' do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }
          it "inserts today's date as a string" do
            block = XmlExtractor.call(xml, :global_merits, 'DATE_CLIENT_VISITED_FIRM')
            expect(block).to have_date_response Time.zone.today.strftime('%d-%m-%Y')
          end
        end

        context '_SYSTEM_PUI_USERID' do
          it "inserts provider's email address" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, '_SYSTEM_PUI_USERID')
              expect(block).to have_text_response legal_aid_application.provider.email
            end
          end
        end

        context 'USER_PROVIDER_FIRM_ID' do
          it "inserts provider's firm id as a number" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'USER_PROVIDER_FIRM_ID')
              expect(block).to have_number_response legal_aid_application.provider.firm.ccms_id
            end
          end
        end

        context 'DATE_ASSESSMENT_STARTED' do
          before { allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today) }
          it "inserts today's date as a string" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'DATE_ASSESSMENT_STARTED')
              expect(block).to have_date_response Time.zone.today.strftime('%d-%m-%Y')
            end
          end
        end

        context 'attributes omitted from payload' do
          it 'should not be present' do
            omitted_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
            end
          end
        end

        context 'BAIL_CONDITIONS_SET' do
          context 'bail conditions set' do
            before { opponent.bail_conditions_set = true }
            it 'is true' do
              block = XmlExtractor.call(xml, :global_merits, 'BAIL_CONDITIONS_SET')
              expect(block).to have_boolean_response true
            end
          end

          context 'bail conditions NOT set' do
            before { opponent.bail_conditions_set = false }
            it 'is false' do
              block = XmlExtractor.call(xml, :global_merits, 'BAIL_CONDITIONS_SET')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'Benefit Checker' do
          context 'BEN_DOB' do
            it "inserts applicant's date of birth as a string" do
              block = XmlExtractor.call(xml, :global_means, 'BEN_DOB')
              expect(block).to have_date_response legal_aid_application.applicant.date_of_birth.strftime('%d-%m-%Y')
            end
          end

          context 'BEN_NI_NO' do
            it "inserts applicant's national insurance number as a string" do
              block = XmlExtractor.call(xml, :global_means, 'BEN_NI_NO')
              expect(block).to have_text_response legal_aid_application.applicant.national_insurance_number
            end
          end
        end

        context 'LAR_INFER_B_1WP1_36A' do
          context 'benefit check result is yes' do
            it 'uses the DWP benefit check result' do
              block = XmlExtractor.call(xml, :global_means, 'LAR_INFER_B_1WP1_36A')
              expect(block).to have_boolean_response true
            end
          end

          context 'benefit check result is no' do
            let(:benefit_check_result) { create :benefit_check_result, :negative }
            before { legal_aid_application.benefit_check_result = benefit_check_result }
            it 'uses the DWP benefit check result' do
              block = XmlExtractor.call(xml, :global_means, 'LAR_INFER_B_1WP1_36A')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'APP_GRANTED_USING_DP' do
          it 'uses the DWP benefit check result' do
            block = XmlExtractor.call(xml, :global_merits, 'APP_GRANTED_USING_DP')
            expect(block).to have_boolean_response legal_aid_application.used_delegated_functions?
          end
        end

        context 'APP_AMEND_TYPE' do
          context 'delegated function used' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            it 'returns SUBDP' do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'APP_AMEND_TYPE')
                expect(block).to have_text_response 'SUBDP'
              end
            end
          end

          context 'delegated functions not used' do
            it 'returns SUB' do
              %i[global_means global_merits].each do |entity|
                block = XmlExtractor.call(xml, entity, 'APP_AMEND_TYPE')
                expect(block).to have_text_response 'SUB'
              end
            end
          end
        end

        context 'EMERGENCY_FURTHER_INFORMATION' do
          let(:block) { XmlExtractor.call(xml, :global_merits, 'EMERGENCY_FURTHER_INFORMATION') }

          context 'delegated function used' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            it 'returns hard coded statement' do
              expect(block).to have_text_response '.'
            end
          end

          context 'delegated function not used' do
            it 'EMERGENCY_FURTHER_INFORMATION block is not present' do
              expect(block).not_to be_present
            end
          end
        end

        context 'GB_INPUT_B_15WP2_8A client is owed money' do
          it 'returns true when applicant is owed money' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_15WP2_8A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when applicant is NOT owed money' do
            allow(legal_aid_application.other_assets_declaration).to receive(:money_owed_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_15WP2_8A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_14WP2_8A vehicle is owned' do
          it 'returns true when applicant owns a vehicle' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_14WP2_8A')
            expect(block).to have_boolean_response true
          end

          context 'GB_INPUT_B_14WP2_8A no vehicle owned' do
            before { legal_aid_application.update(own_vehicle: false) }
            it 'returns false when applicant does NOT own a vehicle' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_14WP2_8A')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'GB_INPUT_B_16WP2_7A client interest in a trust' do
          it 'returns true when client has interest in a trust' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_16WP2_7A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client has NO interest in a trust' do
            allow(legal_aid_application.other_assets_declaration).to receive(:trust_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_16WP2_7A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_12WP2_2A client valuable possessions' do
          it 'returns true' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_12WP2_2A')
            expect(block).to have_boolean_response true
          end

          it 'displays VALPOSSESS_INPUT_T_12WP2_7A' do
            block = XmlExtractor.call(xml, :global_means, 'VALPOSSESS_INPUT_T_12WP2_7A')
            expect(block).to have_text_response 'Aggregate of valuable possessions'
          end

          it 'displays VALPOSSESS_INPUT_C_12WP2_8A' do
            block = XmlExtractor.call(xml, :global_means, 'VALPOSSESS_INPUT_C_12WP2_8A')
            expect(block).to have_currency_response legal_aid_application.other_assets_declaration.valuable_items_value
          end

          context 'when client has NO valuable possessions' do
            before { allow(legal_aid_application.other_assets_declaration).to receive(:valuable_items_value).and_return(nil) }

            it 'returns false' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_12WP2_2A')
              expect(block).to have_boolean_response false
            end

            it 'does not display VALPOSSESS_INPUT_T_12WP2_7A or VALPOSSESS_INPUT_C_12WP2_8A' do
              %i[VALPOSSESS_INPUT_T_12WP2_7A VALPOSSESS_INPUT_T_12WP2_8A].each do |attribute|
                block = XmlExtractor.call(xml, :global_means, attribute)
                expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
              end
            end
          end
        end

        context 'GB_INPUT_B_6WP2_1A client has timeshare' do
          it 'returns true when client has timeshare' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_6WP2_1A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client does NOT have timeshare' do
            allow(legal_aid_application.other_assets_declaration).to receive(:timeshare_property_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_6WP2_1A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_5WP2_1A client owns land' do
          it 'returns true when client owns land' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_5WP2_1A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client does NOT own land' do
            allow(legal_aid_application.other_assets_declaration).to receive(:land_value).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_5WP2_1A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_9WP2_1A client investments' do
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
          context 'no investments of any type' do
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_9WP2_1A')
              expect(block).to have_boolean_response false
            end
          end

          context 'national savings only' do
            let(:policy_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_9WP2_1A')
              expect(block).to have_boolean_response true
            end
          end

          context 'life_assurance_policy_only' do
            let(:ns_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_9WP2_1A')
              expect(block).to have_boolean_response true
            end
          end

          context 'multiple investments' do
            let(:ns_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:plc_shares_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:peps_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            let(:policy_val) { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_9WP2_1A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'GB_INPUT_B_4WP2_1A Does applicant own additional property?' do
          context 'applicant owns addtional property' do
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_4WP2_1A')
              expect(block).to have_boolean_response true
            end
          end

          context 'applicant DOES NOT own additional property' do
            before { expect(legal_aid_application.other_assets_declaration).to receive(:second_home_value).and_return(nil) }
            it 'returns false when client does NOT own additiaonl property ' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_4WP2_1A')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'GB_INPUT_B_5WP1_18A - does the applicant receive a passported benefit?' do
          context 'no passported benefit' do
            before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false) }
            it 'inserts false into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_5WP1_18A')
              expect(block).to have_boolean_response false
            end
          end

          context 'receiving a passported benefit' do
            before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true) }
            it 'inserts true into the attribute block' do
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_5WP1_18A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'GB_INPUT_B_7WP2_1A client bank accounts' do
          it 'returns true when client has bank accounts' do
            random_value = rand(1...1_000_000.0).round(2)
            allow(legal_aid_application.savings_amount).to receive(:offline_current_accounts).and_return(random_value)
            allow(legal_aid_application.savings_amount).to receive(:offline_savings_accounts).and_return(random_value)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_7WP2_1A')
            expect(block).to have_boolean_response true
          end

          context 'GB_INPUT_B_7WP2_1A negative values in bank accounts' do
            it 'returns false when applicant has negative values in bank accounts' do
              random_negative_value = -rand(1...1_000_000.0).round(2)
              allow(legal_aid_application.savings_amount).to receive(:offline_current_accounts).and_return(random_negative_value)
              allow(legal_aid_application.savings_amount).to receive(:offline_savings_accounts).and_return(random_negative_value)
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_7WP2_1A')
              expect(block).to have_boolean_response false
            end
          end

          context 'GB_INPUT_B_7WP2_1A no bank accounts' do
            it 'returns false when applicant does NOT have bank accounts' do
              allow(legal_aid_application.savings_amount).to receive(:offline_current_accounts).and_return(nil)
              allow(legal_aid_application.savings_amount).to receive(:offline_savings_accounts).and_return(nil)
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_7WP2_1A')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'GB_INPUT_B_8WP2_1A client is signatory to other bank accounts' do
          it 'returns true when client is a signatory to other bank accounts' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_8WP2_1A')
            expect(block).to have_boolean_response true
          end

          context 'GB_INPUT_B_8WP2_1A client is not a signatory to other bank accounts' do
            it 'returns false when applicant is NOT a signatory to other bank accounts' do
              allow(legal_aid_application.savings_amount).to receive(:other_person_account).and_return(nil)
              block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_8WP2_1A')
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'GB_INPUT_D_18WP2_1A - application submission date' do
          let(:dummy_date) { Faker::Date.between(from: 20.days.ago, to: Time.zone.today) }
          it 'inserts the submission date into the attribute block' do
            allow(legal_aid_application).to receive(:calculation_date).and_return(dummy_date)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_D_18WP2_1A')
            expect(block).to have_date_response dummy_date.strftime('%d-%m-%Y')
          end
        end

        context 'GB_INPUT_B_10WP2_1A client other savings' do
          it 'returns true when client has other savings' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_10WP2_1A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client does NOT have other savings' do
            allow(legal_aid_application.savings_amount).to receive(:peps_unit_trusts_capital_bonds_gov_stocks).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_10WP2_1A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_13WP2_7A client other policies' do
          it 'returns true when client has other policies' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_13WP2_7A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client does NOT have other policies' do
            allow(legal_aid_application.savings_amount).to receive(:life_assurance_endowment_policy).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_13WP2_7A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_INPUT_B_11WP2_3A client other shares' do
          it 'returns true when client has other shares' do
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_11WP2_3A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when client does NOT have other shares' do
            allow(legal_aid_application.savings_amount).to receive(:plc_shares).and_return(nil)
            block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_11WP2_3A')
            expect(block).to have_boolean_response false
          end
        end

        context 'GB_DECL_B_38WP3_11A application passported' do
          it 'returns true when application is passported' do
            allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true)
            block = XmlExtractor.call(xml, :global_means, 'GB_DECL_B_38WP3_11A')
            expect(block).to have_boolean_response true
          end

          it 'returns false when application is not passported' do
            allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false)
            block = XmlExtractor.call(xml, :global_means, 'GB_DECL_B_38WP3_11A')
            expect(block).to have_boolean_response false
          end
        end

        context 'attributes with specific hard coded values' do
          context 'attributes hard coded to specific values' do
            it 'hard codes country to GBR' do
              block = XmlExtractor.call(xml, :global_means, 'COUNTRY')
              expect(block).to have_text_response 'GBR'
            end

            it 'DEVOLVED_POWERS_CONTRACT_FLAG should be hard coded to Yes - Excluding JR Proceedings' do
              attributes = [
                [:global_means, 'DEVOLVED_POWERS_CONTRACT_FLAG'],
                [:global_merits, 'DEVOLVED_POWERS_CONTRACT_FLAG']
              ]
              attributes.each do |entity_attribute_pair|
                entity, attribute = entity_attribute_pair
                block = XmlExtractor.call(xml, entity, attribute)
                expect(block).to have_text_response 'Yes - Excluding JR Proceedings'
              end
            end
          end

          it 'should be type of boolean hard coded to false' do
            false_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response false
            end
          end

          it 'CASES_FEES_DISTRIBUTED should be hard coded to 1' do
            block = XmlExtractor.call(xml, :global_merits, 'CASES_FEES_DISTRIBUTED')
            expect(block).to have_number_response 1
          end

          context 'LEVEL_OF_SERVICE' do
            it 'is the service level number from the default level of service' do
              service_level_number = legal_aid_application.lead_proceeding_type.default_level_of_service.service_level_number.to_s
              %i[proceeding_merits proceeding].each do |entity|
                block = XmlExtractor.call(xml, entity, 'LEVEL_OF_SERVICE')
                expect(block).to have_text_response service_level_number
              end
            end
          end

          context 'PROCEEDING_LEVEL_OF_SERVICE' do
            it 'should be the name of the lead proceeding default level of service' do
              block = XmlExtractor.call(xml, :proceeding_merits, 'PROCEEDING_LEVEL_OF_SERVICE')
              expect(block).to have_text_response legal_aid_application.lead_proceeding_type.default_level_of_service.name
            end
          end

          it 'CLIENT_INVOLVEMENT_TYPE should be hard coded to A' do
            attributes = [
              [:proceeding_merits, 'CLIENT_INVOLVEMENT_TYPE'],
              [:proceeding, 'CLIENT_INVOLVEMENT_TYPE']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response 'A'
            end
          end

          context 'attributes hard coded to false' do
            it 'should be type of text hard coded to false' do
              attributes = [
                [:global_means, 'COST_LIMIT_CHANGED_FLAG'],
                [:global_merits, 'COST_LIMIT_CHANGED_FLAG']
              ]
              attributes.each do |entity_attribute_pair|
                entity, attribute = entity_attribute_pair
                block = XmlExtractor.call(xml, entity, attribute)
                expect(block).to have_text_response 'false'
              end
            end
          end

          it 'CASES_FEES_DISTRIBUTED should be hard coded to 1' do
            block = XmlExtractor.call(xml, :global_merits, 'CASES_FEES_DISTRIBUTED')
            expect(block).to have_number_response 1
          end

          it 'NEW_APPL_OR_AMENDMENT should be hard coded to APPLICATION' do
            attributes = [
              [:global_means, 'NEW_APPL_OR_AMENDMENT'],
              [:global_merits, 'NEW_APPL_OR_AMENDMENT']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response 'APPLICATION'
            end
          end

          it 'USER_TYPE should be hard coded to EXTERNAL' do
            attributes = [
              [:global_means, 'USER_TYPE'],
              [:global_merits, 'USER_TYPE']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response 'EXTERNAL'
            end
          end

          it 'COUNTRY should be hard coded to GBR' do
            block = XmlExtractor.call(xml, :global_merits, 'COUNTRY')
            expect(block).to have_text_response 'GBR'
          end

          it 'MARITIAL_STATUS should be hard coded to UNKNOWN' do
            block = XmlExtractor.call(xml, :global_means, 'MARITIAL_STATUS')
            expect(block).to have_text_response 'UNKNOWN'
          end

          context 'there is one scope limitation' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            # before do
            #   # the :with_proceeding_types trait sets up both substantive and df scope limitations for the application proceeding type, so
            #   # we have to delete it here because we don't want it
            #   application_proceeding_type.delegated_functions_scope_limitation.destroy!
            # end

            it 'REQUESTED_SCOPE should be hard be populated with the scope limitation code' do
              attributes = [
                [:proceeding, 'REQUESTED_SCOPE'],
                [:proceeding_merits, 'REQUESTED_SCOPE']
              ]
              attributes.each do |entity_attribute_pair|
                entity, attribute = entity_attribute_pair
                block = XmlExtractor.call(xml, entity, attribute)
                expect(block).to have_text_response legal_aid_application.application_proceeding_types.first.assigned_scope_limitations.first.code
              end
            end
          end

          context 'there are multiple scope limitations' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     proceeding_types_count: 2,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            it 'REQUESTED_SCOPE should be hard be populated with MULTIPLE' do
              skip 'Will be fixed when multiple proceeding CCMS generation is tested'
              # Currently is producing two attribute blocks as follows:
              # <Attribute>
              #     <Attribute>REQUESTED_SCOPE</Attribute>
              #     <ResponseType>text</ResponseType>
              #     <ResponseValue>AA003</ResponseValue>
              #     <UserDefinedInd>true</UserDefinedInd>
              # </Attribute>
              # <Attribute>
              #     <Attribute>REQUESTED_SCOPE</Attribute>
              #     <ResponseType>text</ResponseType>
              #     <ResponseValue>AA001</ResponseValue>
              #     <UserDefinedInd>true</UserDefinedInd>
              # </Attribute>
              #
              attributes = [
                [:proceeding, 'REQUESTED_SCOPE'],
                [:proceeding_merits, 'REQUESTED_SCOPE']
              ]
              attributes.each do |entity_attribute_pair|
                entity, attribute = entity_attribute_pair
                block = XmlExtractor.call(xml, entity, attribute)
                expect(block).to have_text_response 'MULTIPLE'
              end
            end
          end

          it 'NEW_OR_EXISTING should be hard coded to NEW' do
            attributes = [
              [:proceeding, 'NEW_OR_EXISTING'],
              [:proceeding_merits, 'NEW_OR_EXISTING']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response 'NEW'
            end
          end

          it 'POA_OR_BILL_FLAG should be hard coded to N/A' do
            block = XmlExtractor.call(xml, :global_means, 'POA_OR_BILL_FLAG')
            expect(block).to have_text_response 'N/A'
          end

          it 'MERITS_ROUTING should be hard coded to SFM' do
            block = XmlExtractor.call(xml, :global_merits, 'MERITS_ROUTING')
            expect(block).to have_text_response 'SFM'
          end

          it 'IS_PASSPORTED should be hard coded to YES' do
            block = XmlExtractor.call(xml, :global_means, 'IS_PASSPORTED')
            expect(block).to have_text_response 'YES'
          end

          it 'should be hard coded with the correct notification' do
            attributes = [
              [:proceeding_merits, 'INJ_RECENT_INCIDENT_DETAIL'],
              [:global_merits, 'INJ_REASON_POLICE_NOT_NOTIFIED'],
              [:global_merits, 'REASON_APPLYING_FHH_LR'],
              [:global_merits, 'REASON_NO_ATTEMPT_TO_SETTLE'],
              [:global_merits, 'REASON_SEPARATE_REP_REQ'],
              [:global_merits, 'MAIN_PURPOSE_OF_APPLICATION'],
              [:global_means, 'LAR_INPUT_T_1WP2_8A']
            ]
            attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_text_response '.'
            end
          end
        end

        context 'legal framework attributes' do
          it 'populates REQ_COST_LIMITATION' do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'REQ_COST_LIMITATION')
              expect(block).to have_currency_response format('%<value>.2f', value: legal_aid_application.default_substantive_cost_limitation)
            end
          end

          it 'populates APP_IS_FAMILY' do
            block = XmlExtractor.call(xml, :global_merits, 'APP_IS_FAMILY')
            expect(block).to have_boolean_response(application_proceeding_type.proceeding_type.ccms_category_law == 'Family')
          end

          it 'populates CAT_OF_LAW_DESCRIPTION' do
            block = XmlExtractor.call(xml, :global_merits, 'CAT_OF_LAW_DESCRIPTION')
            expect(block).to have_text_response application_proceeding_type.proceeding_type.ccms_category_law
          end

          it 'populates CAT_OF_LAW_HIGH_LEVEL' do
            block = XmlExtractor.call(xml, :global_merits, 'CAT_OF_LAW_HIGH_LEVEL')
            expect(block).to have_text_response application_proceeding_type.proceeding_type.ccms_category_law
          end

          it 'populates CAT_OF_LAW_MEANING' do
            block = XmlExtractor.call(xml, :global_merits, 'CAT_OF_LAW_MEANING')
            expect(block).to have_text_response application_proceeding_type.proceeding_type.meaning
          end

          it 'populates CATEGORY_OF_LAW' do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'CATEGORY_OF_LAW')
              expect(block).to have_text_response application_proceeding_type.proceeding_type.ccms_category_law_code
            end
          end

          it 'populates DEFAULT_COST_LIMITATION_MERITS' do
            block = XmlExtractor.call(xml, :global_merits, 'DEFAULT_COST_LIMITATION_MERITS')
            expect(block).to have_currency_response format('%<value>.2f', value: legal_aid_application.default_substantive_cost_limitation)
          end

          it 'populates DEFAULT_COST_LIMITATION' do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'DEFAULT_COST_LIMITATION')
              expect(block).to have_currency_response format('%<value>.2f', value: legal_aid_application.default_substantive_cost_limitation)
            end
          end

          it 'populates MATTER_TYPE' do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'MATTER_TYPE')
              expect(block).to have_text_response application_proceeding_type.proceeding_type.ccms_matter_code
            end
          end

          it 'populates PROCEEDING_NAME' do
            block = XmlExtractor.call(xml, :proceeding_merits, 'PROCEEDING_NAME')
            expect(block).to have_text_response application_proceeding_type.proceeding_type.ccms_code
          end
        end

        context 'SUBSTANTIVE_APP populates correctly' do
          let(:block) { XmlExtractor.call(xml, :global_merits, 'SUBSTANTIVE_APP') }

          context 'substantive' do
            it 'returns true' do
              expect(block).to have_boolean_response true
            end
          end

          context 'delegated_functions' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            it 'returns false' do
              expect(block).to have_boolean_response false
            end
          end
        end

        context 'PROCEEDING_APPLICATION_TYPE populates correctly' do
          let(:block) { XmlExtractor.call(xml, :proceeding_merits, 'PROCEEDING_APPLICATION_TYPE') }

          context 'substantive' do
            it 'returns Substantive' do
              expect(block).to have_text_response 'Substantive'
            end
          end

          context 'delegated functions' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_proceeding_types,
                     :with_delegated_functions,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     populate_vehicle: true,
                     with_bank_accounts: 2,
                     provider: provider,
                     office: office
            end

            it 'returns Both' do
              expect(block).to have_text_response 'Both'
            end
          end
        end

        context 'dummy opponent' do
          it 'hardcodes OPP_RELATIONSHIP_TO_CASE' do
            block = XmlExtractor.call(xml, :opponent, 'OPP_RELATIONSHIP_TO_CASE')
            expect(block).to have_text_response 'Opponent'
          end

          it 'hardcodes OPP_RELATIONSHIP_TO_CLIENT' do
            block = XmlExtractor.call(xml, :opponent, 'OPP_RELATIONSHIP_TO_CLIENT')
            expect(block).to have_text_response 'None'
          end

          it 'hardcodes OTHER_PARTY_ID' do
            block = XmlExtractor.call(xml, :opponent, 'OTHER_PARTY_ID')
            expect(block).to have_text_response 'OPPONENT_7713451'
          end

          it 'hardcodes OTHER_PARTY_NAME' do
            block = XmlExtractor.call(xml, :opponent, 'OTHER_PARTY_NAME')
            expect(block).to have_text_response '.'
          end

          it 'harcodes OTHER_PARTY_NAME_MERITS' do
            block = XmlExtractor.call(xml, :opponent, 'OTHER_PARTY_NAME_MERITS')
            expect(block).to have_text_response '.'
          end

          it 'harcodes OTHER_PARTY_ORG' do
            block = XmlExtractor.call(xml, :opponent, 'OTHER_PARTY_ORG')
            expect(block).to have_boolean_response true
          end

          it 'harcodes OTHER_PARTY_TYPE' do
            block = XmlExtractor.call(xml, :opponent, 'OTHER_PARTY_TYPE')
            expect(block).to have_text_response 'ORGANISATION'
          end

          it 'harcodes RELATIONSHIP_CASE_OPPONENT' do
            block = XmlExtractor.call(xml, :opponent, 'RELATIONSHIP_CASE_OPPONENT')
            expect(block).to have_boolean_response true
          end

          it 'harcodes RELATIONSHIP_NONE' do
            block = XmlExtractor.call(xml, :opponent, 'RELATIONSHIP_NONE')
            expect(block).to have_boolean_response true
          end

          it 'harcodes RELATIONSHIP_TO_CASE' do
            block = XmlExtractor.call(xml, :opponent, 'RELATIONSHIP_TO_CASE')
            expect(block).to have_text_response 'OPP'
          end

          it 'harcodes RELATIONSHIP_TO_CLIENT' do
            block = XmlExtractor.call(xml, :opponent, 'RELATIONSHIP_TO_CLIENT')
            expect(block).to have_text_response 'OPP'
          end
        end

        context 'APPLY_CASE_MEANS_REVIEW' do
          context 'in global means and global merits' do
            let(:determiner) { double ManualReviewDeterminer }

            before { allow(ManualReviewDeterminer).to receive(:new).and_return(determiner) }

            context 'Manual review required' do
              it 'set the attribute to false' do
                allow(determiner).to receive(:manual_review_required?).and_return(true)
                block = XmlExtractor.call(xml, :global_means, 'APPLY_CASE_MEANS_REVIEW')
                expect(block).to have_boolean_response false
                block = XmlExtractor.call(xml, :global_merits, 'APPLY_CASE_MEANS_REVIEW')
                expect(block).to have_boolean_response false
              end
            end

            context 'Manual review not required' do
              it 'sets the attribute to true' do
                allow(determiner).to receive(:manual_review_required?).and_return(false)
                block = XmlExtractor.call(xml, :global_means, 'APPLY_CASE_MEANS_REVIEW')
                expect(block).to have_boolean_response true
                block = XmlExtractor.call(xml, :global_merits, 'APPLY_CASE_MEANS_REVIEW')
                expect(block).to have_boolean_response true
              end
            end
          end
        end

        context 'dummy other_party' do
          it 'hardcodes OTHER_PARTY_ID' do
            block = XmlExtractor.call(xml, :other_party, 'OTHER_PARTY_ID')
            expect(block).to have_text_response 'OPPONENT_7713451'
          end

          it 'harcodes OTHER_PARTY_NAME' do
            block = XmlExtractor.call(xml, :other_party, 'OTHER_PARTY_NAME')
            expect(block).to have_text_response '.'
          end

          it 'harcodes OTHER_PARTY_TYPE' do
            block = XmlExtractor.call(xml, :other_party, 'OTHER_PARTY_TYPE')
            expect(block).to have_text_response 'ORGANISATION'
          end

          it 'harcodes RELATIONSHIP_TO_CASE' do
            block = XmlExtractor.call(xml, :other_party, 'RELATIONSHIP_TO_CASE')
            expect(block).to have_text_response 'OPP'
          end

          it 'harcodes RELATIONSHIP_TO_CLIENT' do
            block = XmlExtractor.call(xml, :other_party, 'RELATIONSHIP_TO_CLIENT')
            expect(block).to have_text_response 'NONE'
          end
        end
      end

      def omitted_attributes # rubocop:disable Metrics/MethodLength
        [
          [:family_statement],
          [:main_dwelling],
          [:main_dwelling, 'MAINTHIRD_INPUT_T_3WP2_12A'],
          [:main_dwelling, 'MAINTHIRD_INPUT_T_3WP2_13A'],
          [:main_dwelling, 'MAINTHIRD_INPUT_N_3WP2_11A'],
          [:family_statement, 'FAMILY_STMT_DETAIL'],
          [:family_statement, 'FAMILY_STATEMENT_INSTANCE'],
          [:change_in_circumstances],
          [:change_in_circumstances, 'CHANGE_CIRC_INPUT_T_33WP3_6A'],
          [:global_means, 'BEN_AWARD_DATE'],
          [:global_means, 'CLIENT_NASS'],
          [:global_means, 'CLIENT_PRISONER'],
          [:global_means, 'CLIENT_VULNERABLE'],
          [:global_means, 'CONFIRMED_NOT_PASSPORTED'],
          [:global_means, 'EMP_INPUT_B_3WP3_60A'],
          [:global_means, 'EMP_INPUT_B_3WP3_62A'],
          [:global_means, 'EMP_INPUT_B_3WP3_63A'],
          [:global_means, 'EMP_INFER_C_15WP3_12A'],
          [:global_means, 'EMP_INFER_C_15WP3_13A'],
          [:global_means, 'EMP_INPUT_D_3WP3_5A'],
          [:global_means, 'EMP_INPUT_N_3WP3_6A'],
          [:global_means, 'EMP_INPUT_T_3WP3_2A'],
          [:global_means, 'EMP_INPUT_T_3WP3_4A'],
          [:global_means, 'EMP_INPUT_T_3WP3_23A'],
          [:global_means, 'EMP_INPUT_T_3WP3_28A'],
          [:global_means, 'EMP_INPUT_T_3WP3_29A'],
          [:global_means, 'GB_DECL_T_38WP3_10A'],
          [:global_means, 'GB_DECL_T_38WP3_116A'],
          [:global_means, 'GB_DECL_T_38WP3_11A'],
          [:global_means, 'GB_DECL_T_38WP3_12A'],
          [:global_means, 'GB_DECL_T_38WP3_13A'],
          [:global_means, 'GB_DECL_T_38WP3_14A'],
          [:global_means, 'GB_DECL_T_38WP3_15A'],
          [:global_means, 'GB_DECL_T_38WP3_16A'],
          [:global_means, 'GB_DECL_T_38WP3_17A'],
          [:global_means, 'GB_DECL_T_38WP3_18A'],
          [:global_means, 'GB_DECL_T_38WP3_19A'],
          [:global_means, 'GB_DECL_T_38WP3_1A'],
          [:global_means, 'GB_DECL_T_38WP3_20A'],
          [:global_means, 'GB_DECL_T_38WP3_21A'],
          [:global_means, 'GB_DECL_T_38WP3_2A'],
          [:global_means, 'GB_DECL_T_38WP3_3A'],
          [:global_means, 'GB_DECL_T_38WP3_4A'],
          [:global_means, 'GB_DECL_T_38WP3_5A'],
          [:global_means, 'GB_DECL_T_38WP3_6A'],
          [:global_means, 'GB_DECL_T_38WP3_7A'],
          [:global_means, 'GB_DECL_T_38WP3_8A'],
          [:global_means, 'GB_DECL_T_38WP3_9A'],
          [:global_means, 'GB_INFER_B_1WP3_419A'],
          [:global_means, 'GB_INFER_B_26WP3_214A'],
          [:global_means, 'GB_INFER_B_3WP2_403A'],
          [:global_means, 'GB_INFER_B_3WP2_404A'],
          [:global_means, 'GB_INFER_C_31WP3_13A'],
          [:global_means, 'GB_INFER_C_28WP4_10A'],
          [:global_means, 'GB_INFER_C_28WP4_20A'],
          [:global_means, 'GB_INPUT_B_1WP3_175A'],
          [:global_means, 'GB_INPUT_B_1WP3_400A'],
          [:global_means, 'GB_INPUT_B_1WP3_401A'],
          [:global_means, 'GB_INPUT_B_12WP3_1A'],
          [:global_means, 'GB_INPUT_B_12WP3_3A'],
          [:global_means, 'GB_INPUT_B_13WP3_1A'],
          [:global_means, 'GB_INPUT_B_13WP3_14A'],
          [:global_means, 'GB_INPUT_B_13WP3_15A'],
          [:global_means, 'GB_INPUT_B_13WP3_2A'],
          [:global_means, 'GB_INPUT_B_13WP3_36A'],
          [:global_means, 'GB_INPUT_B_13WP3_37A'],
          [:global_means, 'GB_INPUT_B_13WP3_49A'],
          [:global_means, 'GB_INPUT_B_13WP3_5A'],
          [:global_means, 'GB_INPUT_B_13WP3_6A'],
          [:global_means, 'GB_INPUT_B_13WP3_7A'],
          [:global_means, 'GB_INPUT_B_14WP3_1A'],
          [:global_means, 'GB_INPUT_B_2WP3_214A'],
          [:global_means, 'GB_INPUT_B_2WP4_2A'],
          [:global_means, 'GB_INPUT_B_21WP3_389A'],
          [:global_means, 'GB_INPUT_B_3WP2_10A'],
          [:global_means, 'GB_INPUT_B_3WP2_20A'],
          [:global_means, 'GB_INPUT_B_3WP2_25A'],
          [:global_means, 'GB_INPUT_B_3WP2_27A'],
          [:global_means, 'GB_INPUT_B_3WP2_8A'],
          [:global_means, 'GB_INPUT_B_3WP3_393A'],
          [:global_means, 'GB_INPUT_B_34WP3_32A'],
          [:global_means, 'GB_INPUT_B_39WP3_52A'],
          [:global_means, 'GB_INPUT_B_39WP3_52A'],
          [:global_means, 'GB_INPUT_B_39WP3_64A'],
          [:global_means, 'GB_INPUT_B_40WP3_64A'],
          [:global_means, 'GB_INPUT_B_41WP3_20A'],
          [:global_means, 'GB_INPUT_B_41WP3_23A'],
          [:global_means, 'GB_INPUT_B_41WP3_32A'],
          [:global_means, 'GB_INPUT_B_6WP3_232A'],
          [:global_means, 'GB_INPUT_B_6WP3_233A'],
          [:global_means, 'GB_INPUT_B_6WP3_234A'],
          [:global_means, 'GB_INPUT_B_6WP3_235A'],
          [:global_means, 'GB_INPUT_B_6WP3_236A'],
          [:global_means, 'GB_INPUT_B_6WP3_237A'],
          [:global_means, 'GB_INPUT_B_6WP3_238A'],
          [:global_means, 'GB_INPUT_B_6WP3_239A'],
          [:global_means, 'GB_INPUT_B_6WP3_241A'],
          [:global_means, 'GB_INPUT_B_6WP3_254A'],
          [:global_means, 'GB_INPUT_B_8WP3_308A'],
          [:global_means, 'GB_INPUT_B_8WP3_310A'],
          [:global_means, 'GB_INPUT_B_9WP3_349A'],
          [:global_means, 'GB_INPUT_B_9WP3_350A'],
          [:global_means, 'GB_INPUT_B_9WP3_351A'],
          [:global_means, 'GB_INPUT_B_9WP3_352A'],
          [:global_means, 'GB_INPUT_B_9WP3_353A'],
          [:global_means, 'GB_INPUT_B_9WP3_356A'],
          [:global_means, 'GB_INPUT_C_13WP3_3A'],
          [:global_means, 'GB_INPUT_C_13WP3_4A'],
          [:global_means, 'GB_INPUT_C_13WP3_12A'],
          [:global_means, 'GB_INPUT_C_3WP2_5A'],
          [:global_means, 'GB_INPUT_C_3WP2_7A'],
          [:global_means, 'GB_INPUT_C_6WP3_228A'],
          [:global_means, 'GB_INPUT_N_3WP2_14A'],
          [:global_means, 'GB_INPUT_N_3WP2_4A'],
          [:global_means, 'GB_INPUT_N_6WP3_231A'],
          [:global_means, 'GB_INPUT_T_2WP3_50A'],
          [:global_means, 'GB_INPUT_T_3WP2_3A'],
          [:global_means, 'GB_INPUT_T_6WP3_229A'],
          [:global_means, 'GB_PROC_B_1WP4_99A'],
          [:global_means, 'LAR_RFLAG_B_37WP2_41A'],
          [:global_means, 'MEANS_OPA_RELEASE'],
          [:global_means, 'MEANS_REPORT_BACKLOG_TAG'],
          [:global_means, 'MEANS_REQD'],
          [:global_means, 'MEANS_ROUTING'],
          [:global_means, 'OUT_EMP_INFER_C_15WP3_11A'],
          [:global_means, 'OUT_GB_INFER_C_14WP4_19A'],
          [:global_means, 'OUT_GB_INFER_C_14WP4_3A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_133A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_134A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_135A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_140A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_141A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_142A'],
          [:global_means, 'OUT_GB_INFER_C_15WP3_143A'],
          [:global_means, 'OUT_GB_INFER_C_16WP4_3A'],
          [:global_means, 'OUT_GB_INFER_C_16WP4_4A'],
          [:global_means, 'OUT_GB_INFER_C_17WP4_1A'],
          [:global_means, 'OUT_GB_INFER_C_18WP3_219A'],
          [:global_means, 'OUT_GB_INFER_C_18WP3_226A'],
          [:global_means, 'OUT_GB_INFER_C_18WP3_227A'],
          [:global_means, 'OUT_GB_INFER_C_18WP3_407A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_101A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_102A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_104A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_105A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_106A'],
          [:global_means, 'OUT_GB_INFER_C_19WP2_109A'],
          [:global_means, 'OUT_GB_INFER_C_19WP3_144A'],
          [:global_means, 'OUT_GB_INFER_C_20WP2_101A'],
          [:global_means, 'OUT_GB_INFER_C_20WP2_104A'],
          [:global_means, 'OUT_GB_INFER_C_21WP2_101A'],
          [:global_means, 'OUT_GB_INFER_C_21WP2_104A'],
          [:global_means, 'OUT_GB_INFER_C_21WP3_162A'],
          [:global_means, 'OUT_GB_INFER_C_21WP4_1A'],
          [:global_means, 'OUT_GB_INFER_C_22WP3_150A'],
          [:global_means, 'OUT_GB_INFER_C_22WP3_155A'],
          [:global_means, 'OUT_GB_INFER_C_23WP3_158A'],
          [:global_means, 'OUT_GB_INFER_C_23WP3_159A'],
          [:global_means, 'OUT_GB_INFER_C_23WP3_160A'],
          [:global_means, 'OUT_GB_INFER_C_23WP3_161A'],
          [:global_means, 'OUT_GB_INFER_C_24WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_24WP2_102A'],
          [:global_means, 'OUT_GB_INFER_C_24WP4_1A'],
          [:global_means, 'OUT_GB_INFER_C_25WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_25WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_25WP2_108A'],
          [:global_means, 'OUT_GB_INFER_C_25WP3_167A'],
          [:global_means, 'OUT_GB_INFER_C_26WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_26WP2_105A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_182A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_186A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_194A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_197A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_217A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_218A'],
          [:global_means, 'OUT_GB_INFER_C_26WP3_219A'],
          [:global_means, 'OUT_GB_INFER_C_27WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_27WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_27WP3_216A'],
          [:global_means, 'OUT_GB_INFER_C_27WP3_218A'],
          [:global_means, 'OUT_GB_INFER_C_28WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_28WP4_2A'],
          [:global_means, 'OUT_GB_INFER_C_28WP4_3A'],
          [:global_means, 'OUT_GB_INFER_C_29WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_29WP4_1A'],
          [:global_means, 'OUT_GB_INFER_C_30WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_30WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_30WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_30WP3_2A'],
          [:global_means, 'OUT_GB_INFER_C_30WP4_1A'],
          [:global_means, 'OUT_GB_INFER_C_30WP4_2A'],
          [:global_means, 'OUT_GB_INFER_C_31WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_31WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_10A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_11A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_12A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_14A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_2A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_4A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_6A'],
          [:global_means, 'OUT_GB_INFER_C_31WP3_9A'],
          [:global_means, 'OUT_GB_INFER_C_32WP2_102A'],
          [:global_means, 'OUT_GB_INFER_C_32WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_33WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_33WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_33WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_34WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_34WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_1A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_3A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_408A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_4A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_6A'],
          [:global_means, 'OUT_GB_INFER_C_34WP3_9A'],
          [:global_means, 'OUT_GB_INFER_C_35WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_35WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_36WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_36WP2_102A'],
          [:global_means, 'OUT_GB_INFER_C_37WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_37WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_38WP2_100A'],
          [:global_means, 'OUT_GB_INFER_C_38WP2_102A'],
          [:global_means, 'OUT_GB_INFER_C_38WP2_103A'],
          [:global_means, 'OUT_GB_INFER_C_40WP2_101A'],
          [:global_means, 'OUT_GB_INFER_C_40WP2_102A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_371A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_372A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_373A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_374A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_375A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_376A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_377A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_378A'],
          [:global_means, 'OUT_GB_INPUT_C_20WP3_379A'],
          [:global_means, 'OUT_GB_PROC_C_34WP3_12A'],
          [:global_means, 'OUT_INCOME_CONT'],
          [:global_means, 'PROVIDER_CASE_REFERENCE'],
          [:global_means, 'PUI_CLIENT_INCOME_CONT'],
          [:global_means, 'RB_VERSION_DATE_MEANS'],
          [:global_means, 'RB_VERSION_NUMBER_MEANS'],
          [:global_means, 'SA_SCREEN10_1WP1_NONMEANS'],
          [:global_means, 'SA_SCREEN3_17WP2_1CAPASSESS'],
          [:global_merits, '_SYSTEM_PUI_CONTEXT'],
          [:global_merits, '_SYSTEM_PUI_URL'],
          [:global_merits, 'APP_CARE_SUPERVISION'],
          [:global_merits, 'APP_DIV_JUDSEP_DISSOLUTION_CP'],
          [:global_merits, 'APP_INC_CHILD_ABDUCTION'],
          [:global_merits, 'APP_INC_CHILDREN_PROCS'],
          [:global_merits, 'APP_INC_SECURE_ACCOM'],
          [:global_merits, 'APP_INCLUDES_IMMIGRATION_PROCS'],
          [:global_merits, 'APP_INCLUDES_INQUEST_PROCS'],
          [:global_merits, 'APP_INCLUDES_RELATED_PROCS'],
          [:global_merits, 'APP_INCLUDES_SCA_PROCS'],
          [:global_merits, 'APP_IS_SCA_RELATED'],
          [:global_merits, 'APP_POTENTIAL_NON_MERITS'],
          [:global_merits, 'APP_RELATES_EPO_EXTENDEPO_SAO'],
          [:global_merits, 'APP_SCA_NON_MERITS_TESTED'],
          [:global_merits, 'APPLICATION_CAN_BE_SUBMITTED'],
          [:global_merits, 'ATTEND_URGENT_HEARING'],
          [:global_merits, 'CAFCASS_EXPT_RPT_RECEIVED'],
          [:global_merits, 'CASE_OWNER_COMPLEX_MERITS'],
          [:global_merits, 'CASE_OWNER_IMMIGRATION'],
          [:global_merits, 'CASE_OWNER_MENTAL_HEALTH'],
          [:global_merits, 'CASE_OWNER_SCA'],
          [:global_merits, 'CASE_OWNER_SCU'],
          [:global_merits, 'CASE_OWNER_VHCC'],
          [:global_merits, 'CERTIFICATE_PREDICTED_COSTS'],
          [:global_merits, 'CHILD_CLIENT'],
          [:global_merits, 'CLIENT_CIVIL_PARTNER'],
          [:global_merits, 'CLIENT_CIVIL_PARTNER_DISSOLVE'],
          [:global_merits, 'CLIENT_COHABITING'],
          [:global_merits, 'CLIENT_DIVORCED'],
          [:global_merits, 'CLIENT_JUDICIALLY_SEPARATED'],
          [:global_merits, 'CLIENT_MARITAL_STATUS'],
          [:global_merits, 'CLIENT_MARRIED'],
          [:global_merits, 'CLIENT_SINGLE'],
          [:global_merits, 'CLIENT_WIDOWED'],
          [:global_merits, 'CLINICAL_NEGLIGENCE'],
          [:global_merits, 'COMMUNITY_CARE'],
          [:global_merits, 'COPY_CA_FINDING_OF_FACT'],
          [:global_merits, 'COPY_CA_POLICE_CAUTION'],
          [:global_merits, 'COPY_DV_CONVICTION'],
          [:global_merits, 'COPY_DV_IDVA'],
          [:global_merits, 'COPY_DV_POLICE_CAUTION_2A'],
          [:global_merits, 'COUNTY_COURT'],
          [:global_merits, 'COURT_OF_APPEAL'],
          [:global_merits, 'CRIME'],
          [:global_merits, 'CROSS_BORDER_DISPUTES_GLOBAL'],
          [:global_merits, 'CROWN_COURT'],
          [:global_merits, 'CURRENT_CERT_EMERGENCY'],
          [:global_merits, 'CURRENT_CERT_SUBSTANTIVE'],
          [:global_merits, 'DEC_AGAINST_INSTRUCTIONS'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA02A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA10A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA11A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA12A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA13A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA14A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA15A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA2A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA3A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA5A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA6A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA7A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA8A'],
          [:global_merits, 'DEC_CLIENT_TEXT_PARA9A'],
          [:global_merits, 'DECLARATION_CLIENT_TEXT'],
          [:global_merits, 'DECLARATION_IS_CLIENTS'],
          [:global_merits, 'DECLARATION_IS_REPRESENTATIVES'],
          [:global_merits, 'DP_WITH_JUDICIAL_REVIEW'],
          [:global_merits, 'DV_FIN_ABUSE'],
          [:global_merits, 'DV_LEGAL_HELP_PROVIDED'],
          [:global_merits, 'ECF20A'],
          [:global_merits, 'ECFCA_1A'],
          [:global_merits, 'ECFCA_2A'],
          [:global_merits, 'ECFCA_3A'],
          [:global_merits, 'ECFCA_4A'],
          [:global_merits, 'ECFCA_5A'],
          [:global_merits, 'ECFCA_6A'],
          [:global_merits, 'ECFCA_7A'],
          [:global_merits, 'ECFCA_8A'],
          [:global_merits, 'ECFDV_14A'],
          [:global_merits, 'ECFDV_16A'],
          [:global_merits, 'ECFDV_17A'],
          [:global_merits, 'ECFDV_19A'],
          [:global_merits, 'ECFDV_20A'],
          [:global_merits, 'ECFDV_21A'],
          [:global_merits, 'ECFDV_22A'],
          [:global_merits, 'ECFDV_23A'],
          [:global_merits, 'ECFDV_25A'],
          [:global_merits, 'ECFDV_26A'],
          [:global_merits, 'ECFDV_27A'],
          [:global_merits, 'ECFDV_28A'],
          [:global_merits, 'ECFDV_29A'],
          [:global_merits, 'ECFDV_30A'],
          [:global_merits, 'ECFDV_31A'],
          [:global_merits, 'ECFDV_32A'],
          [:global_merits, 'ECFDV_33A'],
          [:global_merits, 'EDUCATION'],
          [:global_merits, 'EMERGENCY_DEC_SIGNED'],
          [:global_merits, 'EMERGENCY_DPS_APP_AMD'],
          [:global_merits, 'EMPLOYMENT_APPEAL_TRIBUNAL'],
          [:global_merits, 'FAM_CERT_PREDICTED_COSTS'],
          [:global_merits, 'FIRST_TIER_TRIBUNAL_CARE_STAND'],
          [:global_merits, 'FIRST_TIER_TRIBUNAL_IMM_ASY'],
          [:global_merits, 'FIRST_TIER_TRIBUNAL_TAXATION'],
          [:global_merits, 'HIGH_COURT'],
          [:global_merits, 'HOUSING'],
          [:global_merits, 'IMMIGRATION'],
          [:global_merits, 'IMMIGRATION_CT_OF_APPEAL'],
          [:global_merits, 'IMMIGRATION_QUESTION_APP'],
          [:global_merits, 'ISSUE_URGENT_PROCEEDINGS'],
          [:global_merits, 'LAR_CHILD_ABUSE_IDENTITY'],
          [:global_merits, 'LAR_CHILD_ABUSE_RISK'],
          [:global_merits, 'LAR_DV_VICTIM'],
          [:global_merits, 'LAR_SCOPE_FLAG'],
          [:global_merits, 'LEGAL_HELP_COSTS_TO_DATE'],
          [:global_merits, 'LEGAL_HELP_PROVIDED'],
          [:global_merits, 'LEGALLY_LINKED_SCU'],
          [:global_merits, 'LEGALLY_LINKED_SIU'],
          [:global_merits, 'LEGALLY_LINKED_VHCC'],
          [:global_merits, 'LIMITATION_PERIOD_TO_EXPIRE'],
          [:global_merits, 'MAGISTRATES_COURT'],
          [:global_merits, 'MARITIAL_STATUS'],
          [:global_merits, 'MATTER_IS_SWPI'],
          [:global_merits, 'MEDIATION_APPLICABLE'],
          [:global_merits, 'MENTAL_HEAL_QUESTION_APPLIES'],
          [:global_merits, 'MENTAL_HEALTH'],
          [:global_merits, 'MENTAL_HEALTH_REVIEW_TRIBUNAL'],
          [:global_merits, 'MERITS_BACKLOG_REPORT_TAG'],
          [:global_merits, 'MERITS_CERT_PREDICTED_COSTS'],
          [:global_merits, 'MERITS_OPA_RELEASE'],
          [:global_merits, 'MERITS_ROUTING_NAME'],
          [:global_merits, 'MERITS_SUBMISSION_PAGE'],
          [:global_merits, 'NEW_APPLICATION'],
          [:global_merits, 'POA_OR_BILL_FLAG'],
          [:global_merits, 'PRE_CERT_COSTS'],
          [:global_merits, 'PREP_OF_STATEMENT_PAPERS'],
          [:global_merits, 'PROCS_INCLUDE_CHILD'],
          [:global_merits, 'PROPORTIONALITY_QUESTION_APP'],
          [:global_merits, 'PROSCRIBED_ORG_APPEAL_COMM'],
          [:global_merits, 'PROVIDER_CASE_REFERENCE'],
          [:global_merits, 'PROVIDER_HAS_DP'],
          [:global_merits, 'PUB_AUTH_QUESTION_APPLIES'],
          [:global_merits, 'PUBLIC_LAW_NON_FAMILY'],
          [:global_merits, 'RB_VERSION_DATE_MERITS'],
          [:global_merits, 'RB_VERSION_NUMBER_MERITS'],
          [:global_merits, 'REQUESTED_COST_LIMIT_OVER_25K'],
          [:global_merits, 'RISK_SCA_PR'],
          [:global_merits, 'ROUTING_COMPLEX_MERITS'],
          [:global_merits, 'ROUTING_IMMIGRATION'],
          [:global_merits, 'ROUTING_MENTAL_HEALTH'],
          [:global_merits, 'ROUTING_SCU'],
          [:global_merits, 'ROUTING_STD_FAMILY_MERITS'],
          [:global_merits, 'ROUTING_VHCC'],
          [:global_merits, 'SA_INTRODUCTION'],
          [:global_merits, 'SCA_APPEAL_INCLUDED'],
          [:global_merits, 'SCA_AUTO_GRANT'],
          [:global_merits, 'SMOD_APPLICABLE_TO_MATTER'],
          [:global_merits, 'SPECIAL_CHILDREN_ACT_APP'],
          [:global_merits, 'SPECIAL_IMM_APPEAL_COMMISSION'],
          [:global_merits, 'SUPREME_COURT'],
          [:global_merits, 'UPPER_TRIBUNAL_IMM_ASY'],
          [:global_merits, 'UPPER_TRIBUNAL_MENTAL_HEALTH'],
          [:global_merits, 'UPPER_TRIBUNAL_OTHER'],
          [:global_merits, 'URGENT_APPLICATION'],
          [:global_merits, 'URGENT_APPLICATION_TAG'],
          [:global_merits, 'URGENT_DIRECTIONS'],
          [:global_merits, 'CHILD_MUST_BE_INCLUDED'],
          [:opponent, 'OPPONENT_DOB'],
          [:opponent, 'OPPONENT_DOB_MERITS'],
          [:proceeding, 'PROC_UPPER_TRIBUNAL'],
          [:proceeding_merits, 'ACTION_DAMAGES_AGAINST_POLICE'],
          [:proceeding_merits, 'APPEAL_IN_SUPREME_COURT'],
          [:proceeding_merits, 'CLIENT_BRINGING_OR_DEFENDING'],
          [:proceeding_merits, 'CLIENT_DEFENDANT_3RD_PTY'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_APPELLANT'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_BRING_3RD_PTY'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_BRING_COUNTER'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_BRINGING_PROCS'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_CHILD'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_DEF_COUNTER'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_DEFEND_PROCS'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_INTERPLEADER'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_INTERVENOR'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_JOINED_PARTY'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_OTHER'],
          [:proceeding_merits, 'CLIENT_INV_TYPE_PERSONAL_REP'],
          [:proceeding_merits, 'CLIENT_INVOLVEMENT'],
          [:proceeding_merits, 'COUNSEL_FEE_FAMILY'],
          [:proceeding_merits, 'CROSS_BORDER_DISPUTES_C'],
          [:proceeding_merits, 'DAMAGES_AGAINST_POLICE'],
          [:proceeding_merits, 'DISBURSEMENT_COST_FAMILY'],
          [:proceeding_merits, 'DOM_VIOLENCE_WAIVER_APPLIES'],
          [:proceeding_merits, 'EXPERT_COST_FAMILY'],
          [:proceeding_merits, 'FAM_PROSP_50_OR_BETTER'],
          [:proceeding_merits, 'FAM_PROSP_BORDER_UNCERT_POOR'],
          [:proceeding_merits, 'FAM_PROSP_BORDERLINE_UNCERT'],
          [:proceeding_merits, 'FAM_PROSP_GOOD'],
          [:proceeding_merits, 'FAM_PROSP_MARGINAL'],
          [:proceeding_merits, 'FAM_PROSP_POOR'],
          [:proceeding_merits, 'FAM_PROSP_UNCERTAIN'],
          [:proceeding_merits, 'FAM_PROSP_VERY_GOOD'],
          [:proceeding_merits, 'FAM_PROSP_VERY_POOR'],
          [:proceeding_merits, 'HIGH_COST_CASE_ROUTING'],
          [:proceeding_merits, 'IMMIGRATION_QUESTION_APPLIES'],
          [:proceeding_merits, 'LEAD_PROCEEDING_MERITS'],
          [:proceeding_merits, 'LEVEL_OF_SERV_FHH'],
          [:proceeding_merits, 'LEVEL_OF_SERV_FR'],
          [:proceeding_merits, 'LEVEL_OF_SERV_IH'],
          [:proceeding_merits, 'LEVEL_OF_SERV_INQUEST'],
          [:proceeding_merits, 'MATRIMONIAL_PROCEEDING'],
          [:proceeding_merits, 'MATTER_TYPE_CHILD_ABDUCTION'],
          [:proceeding_merits, 'MATTER_TYPE_PRIVATE_FAMILY'],
          [:proceeding_merits, 'MATTER_TYPE_PUBLIC_FAMILY'],
          [:proceeding_merits, 'MATTER_TYPE_STAND_ALONE'],
          [:proceeding_merits, 'NEW_OR_EXISTING_MERITS'],
          [:proceeding_merits, 'NON_QUANTIFIABLE_REMEDY'],
          [:proceeding_merits, 'OVERWHELMING_IMPORTANCE'],
          [:proceeding_merits, 'PRIVATE_FUNDING_APPLICABLE'],
          [:proceeding_merits, 'PRIVATE_FUNDING_CONSIDERED'],
          [:proceeding_merits, 'PROC_AVAILABLE_AMENDMENT_ONLY'],
          [:proceeding_merits, 'PROC_CA_GATEWAY_APPLIES'],
          [:proceeding_merits, 'PROC_CARE_SUPERV_OR_RELATED'],
          [:proceeding_merits, 'PROC_CHILD_ABDUCTION'],
          [:proceeding_merits, 'PROC_DEFAULT_LEVEL_OF_SERVICE'],
          [:proceeding_merits, 'PROC_DELEGATED_FUNCTIONS_DATE'],
          [:proceeding_merits, 'PROC_DV_GATEWAY_APPLIES'],
          [:proceeding_merits, 'PROC_FIN_REP_CATEGORY'],
          [:proceeding_merits, 'PROC_IMMIGRATION_RELATED'],
          [:proceeding_merits, 'PROC_INVOLVING_CHILDREN'],
          [:proceeding_merits, 'PROC_INVOLVING_FIN_AND_PROP'],
          [:proceeding_merits, 'PROC_INVOLVING_INJUNCTION'],
          [:proceeding_merits, 'PROC_IS_MERITS_TESTED'],
          [:proceeding_merits, 'PROC_IS_SCA_APPEAL'],
          [:proceeding_merits, 'PROC_IS_SCA_OR_RELATED'],
          [:proceeding_merits, 'PROC_LAR_GATEWAY'],
          [:proceeding_merits, 'PROC_MATTER_TYPE_DESC'],
          [:proceeding_merits, 'PROC_MATTER_TYPE_MEANING'],
          [:proceeding_merits, 'PROC_MEANING'],
          [:proceeding_merits, 'PROC_OUTCOME_NO_OUTCOME'],
          [:proceeding_merits, 'PROC_OUTCOME_RECORDED'],
          [:proceeding_merits, 'PROC_POSSESSION'],
          [:proceeding_merits, 'PROC_PREDICTED_COST_FAMILY'],
          [:proceeding_merits, 'PROC_REGISTER_FOREIGN_ORDER'],
          [:proceeding_merits, 'PROC_RELATED_PROCEEDING'],
          [:proceeding_merits, 'PROC_RELATED_SCA_OR_RELATED'],
          [:proceeding_merits, 'PROC_SCHED1_TRUE'],
          [:proceeding_merits, 'PROC_SUBJECT_TO_DP_CHECK'],
          [:proceeding_merits, 'PROC_SUBJECT_TO_MEDIATION'],
          [:proceeding_merits, 'PROC_UPPER_TRIBUNAL'],
          [:proceeding_merits, 'PROCEEDING_CASE_OWNER_SCU'],
          [:proceeding_merits, 'PROCEEDING_DESCRIPTION'],
          [:proceeding_merits, 'PROCEEDING_INCLUDES_CHILD'],
          [:proceeding_merits, 'PROCEEDING_JUDICIAL_REVIEW'],
          [:proceeding_merits, 'PROCEEDING_LIMITATION_DESC'],
          [:proceeding_merits, 'PROCEEDING_LIMITATION_MEANING'],
          [:proceeding_merits, 'PROCEEDING_STAND_ALONE'],
          [:proceeding_merits, 'PROCEEDING_TYPE'],
          [:proceeding_merits, 'PROFIT_COST_FAMILY'],
          [:proceeding_merits, 'PROPORTIONALITY_QUESTION'],
          [:proceeding_merits, 'PROSPECTS_OF_SUCCESS'],
          [:proceeding_merits, 'ROUTING_FOR_PROCEEDING'],
          [:proceeding_merits, 'SCA_APPEAL_FINAL_ORDER'],
          [:proceeding_merits, 'SIGNIFICANT_WIDER_PUB_INTEREST'],
          [:proceeding_merits, 'SMOD_APPLICABLE'],
          [:proceeding_merits, 'WORK_IN_SCH_ONE']
        ]
      end

      def false_attributes # rubocop:disable Metrics/MethodLength
        [
          [:global_means, 'GB_INPUT_B_1WP2_14A'],
          [:global_means, 'GB_INPUT_B_1WP2_22A'],
          [:global_means, 'GB_INPUT_B_1WP2_27A'],
          [:global_means, 'GB_INPUT_B_1WP2_36A'],
          [:global_means, 'GB_INPUT_B_1WP3_165A'],
          [:global_means, 'GB_INFER_B_1WP1_1A'],
          [:global_means, 'GB_INPUT_B_14WP2_7A'],
          [:global_means, 'GB_INPUT_B_17WP2_7A'],
          [:global_means, 'GB_INPUT_B_17WP2_8A'],
          [:global_means, 'GB_INPUT_B_18WP2_2A'],
          [:global_means, 'GB_INPUT_B_18WP2_4A'],
          [:global_means, 'GB_INPUT_B_1WP1_2A'],
          [:global_means, 'GB_INPUT_B_1WP4_1B'],
          [:global_means, 'GB_INPUT_B_1WP4_2B'],
          [:global_means, 'GB_INPUT_B_1WP4_3B'],
          [:global_means, 'GB_INPUT_B_39WP3_70B'],
          [:global_means, 'GB_INPUT_B_41WP3_40A'],
          [:global_means, 'GB_INPUT_B_5WP1_22A'],
          [:global_means, 'GB_INPUT_B_5WP1_3A'],
          [:global_means, 'GB_PROC_B_39WP3_14A'],
          [:global_means, 'GB_PROC_B_39WP3_15A'],
          [:global_means, 'GB_PROC_B_39WP3_16A'],
          [:global_means, 'GB_PROC_B_39WP3_17A'],
          [:global_means, 'GB_PROC_B_39WP3_18A'],
          [:global_means, 'GB_PROC_B_39WP3_19A'],
          [:global_means, 'GB_PROC_B_39WP3_1A'],
          [:global_means, 'GB_PROC_B_39WP3_20A'],
          [:global_means, 'GB_PROC_B_39WP3_21A'],
          [:global_means, 'GB_PROC_B_39WP3_22A'],
          [:global_means, 'GB_PROC_B_39WP3_23A'],
          [:global_means, 'GB_PROC_B_39WP3_24A'],
          [:global_means, 'GB_PROC_B_39WP3_25A'],
          [:global_means, 'GB_PROC_B_39WP3_29A'],
          [:global_means, 'GB_PROC_B_39WP3_2A'],
          [:global_means, 'GB_PROC_B_39WP3_30A'],
          [:global_means, 'GB_PROC_B_39WP3_31A'],
          [:global_means, 'GB_PROC_B_39WP3_32A'],
          [:global_means, 'GB_PROC_B_39WP3_33A'],
          [:global_means, 'GB_PROC_B_39WP3_34A'],
          [:global_means, 'GB_PROC_B_39WP3_35A'],
          [:global_means, 'GB_PROC_B_39WP3_36A'],
          [:global_means, 'GB_PROC_B_39WP3_37A'],
          [:global_means, 'GB_PROC_B_39WP3_38A'],
          [:global_means, 'GB_PROC_B_39WP3_39A'],
          [:global_means, 'GB_PROC_B_39WP3_40A'],
          [:global_means, 'GB_PROC_B_39WP3_41A'],
          [:global_means, 'GB_PROC_B_39WP3_42A'],
          [:global_means, 'GB_PROC_B_39WP3_46A'],
          [:global_means, 'GB_PROC_B_39WP3_47A'],
          [:global_means, 'GB_PROC_B_39WP3_7A'],
          [:global_means, 'GB_PROC_B_39WP3_8A'],
          [:global_means, 'GB_PROC_B_40WP3_10A'],
          [:global_means, 'GB_PROC_B_40WP3_13A'],
          [:global_means, 'GB_PROC_B_40WP3_15A'],
          [:global_means, 'GB_PROC_B_40WP3_17A'],
          [:global_means, 'GB_PROC_B_40WP3_19A'],
          [:global_means, 'GB_PROC_B_40WP3_1A'],
          [:global_means, 'GB_PROC_B_40WP3_21A'],
          [:global_means, 'GB_PROC_B_40WP3_23A'],
          [:global_means, 'GB_PROC_B_40WP3_25A'],
          [:global_means, 'GB_PROC_B_40WP3_27A'],
          [:global_means, 'GB_PROC_B_40WP3_29A'],
          [:global_means, 'GB_PROC_B_40WP3_2A'],
          [:global_means, 'GB_PROC_B_40WP3_31A'],
          [:global_means, 'GB_PROC_B_40WP3_33A'],
          [:global_means, 'GB_PROC_B_40WP3_35A'],
          [:global_means, 'GB_PROC_B_40WP3_39A'],
          [:global_means, 'GB_PROC_B_40WP3_3A'],
          [:global_means, 'GB_PROC_B_40WP3_40A'],
          [:global_means, 'GB_PROC_B_40WP3_41A'],
          [:global_means, 'GB_PROC_B_40WP3_42A'],
          [:global_means, 'GB_PROC_B_40WP3_43A'],
          [:global_means, 'GB_PROC_B_40WP3_44A'],
          [:global_means, 'GB_PROC_B_40WP3_45A'],
          [:global_means, 'GB_PROC_B_40WP3_46A'],
          [:global_means, 'GB_PROC_B_40WP3_47A'],
          [:global_means, 'GB_PROC_B_40WP3_48A'],
          [:global_means, 'GB_PROC_B_40WP3_49A'],
          [:global_means, 'GB_PROC_B_40WP3_4A'],
          [:global_means, 'GB_PROC_B_40WP3_50A'],
          [:global_means, 'GB_PROC_B_40WP3_51A'],
          [:global_means, 'GB_PROC_B_40WP3_52A'],
          [:global_means, 'GB_PROC_B_40WP3_53A'],
          [:global_means, 'GB_PROC_B_40WP3_54A'],
          [:global_means, 'GB_PROC_B_40WP3_55A'],
          [:global_means, 'GB_PROC_B_40WP3_56A'],
          [:global_means, 'GB_PROC_B_40WP3_57A'],
          [:global_means, 'GB_PROC_B_40WP3_58A'],
          [:global_means, 'GB_PROC_B_40WP3_9A'],
          [:global_means, 'GB_PROC_B_41WP3_10A'],
          [:global_means, 'GB_PROC_B_41WP3_11A'],
          [:global_means, 'GB_PROC_B_41WP3_12A'],
          [:global_means, 'GB_PROC_B_41WP3_13A'],
          [:global_means, 'GB_PROC_B_41WP3_14A'],
          [:global_means, 'GB_PROC_B_41WP3_15A'],
          [:global_means, 'GB_PROC_B_41WP3_16A'],
          [:global_means, 'GB_PROC_B_41WP3_17A'],
          [:global_means, 'GB_PROC_B_41WP3_18A'],
          [:global_means, 'GB_PROC_B_41WP3_1A'],
          [:global_means, 'GB_PROC_B_41WP3_20A'],
          [:global_means, 'GB_PROC_B_41WP3_2A'],
          [:global_means, 'GB_PROC_B_41WP3_3A'],
          [:global_means, 'GB_PROC_B_41WP3_4A'],
          [:global_means, 'GB_PROC_B_41WP3_5A'],
          [:global_means, 'GB_PROC_B_41WP3_6A'],
          [:global_means, 'GB_PROC_B_41WP3_7A'],
          [:global_means, 'GB_PROC_B_41WP3_8A'],
          [:global_means, 'GB_PROC_B_41WP3_9A'],
          [:global_means, 'GB_RFLAG_B_2WP3_01A'],
          [:global_means, 'GB_ROUT_B_43WP3_13A'],
          [:global_means, 'HIGH_PROFILE'],
          [:global_means, 'LAR_PROC_B_39WP3_53A'],
          [:global_means, 'LAR_PROC_B_39WP3_54A'],
          [:global_means, 'LAR_PROC_B_40WP3_29A'],
          [:global_means, 'LAR_PROC_B_40WP3_30A'],
          [:global_means, 'LAR_PROC_B_40WP3_31A'],
          [:global_means, 'LAR_PROC_B_40WP3_32A'],
          [:global_means, 'LAR_INPUT_B_37WP2_4A'],
          [:global_means, 'LAR_PER_RES_INPUT_B_37WP2_7A'],
          [:global_means, 'MEANS_EVIDENCE_REQD'],
          [:global_means, 'MEANS_TASK_AUTO_GEN'],
          [:global_merits, 'ACTION_AGAINST_POLICE'],
          [:global_merits, 'ACTUAL_LIKELY_COSTS_EXCEED_25K'],
          [:global_merits, 'AMENDMENT'],
          [:global_merits, 'APP_BROUGHT_BY_PERSONAL_REP'],
          [:global_merits, 'COPY_SEPARATE_STATEMENT'],
          [:global_merits, 'CLIENT_HAS_RECEIVED_LA_BEFORE'],
          [:global_merits, 'COST_LIMIT_CHANGED'],
          [:global_merits, 'COURT_ATTEND_IN_LAST_12_MONTHS'],
          [:global_merits, 'DECLARATION_IDENTIFIER'],
          [:global_merits, 'ECF_FLAG'],
          [:global_merits, 'EVID_DEC_AGAINST_INSTRUCTIONS'],
          [:global_merits, 'EVIDENCE_AMD_CORRESPONDENCE'],
          [:global_merits, 'EVIDENCE_AMD_COUNSEL_OPINION'],
          [:global_merits, 'EVIDENCE_AMD_COURT_ORDER'],
          [:global_merits, 'EVIDENCE_AMD_EXPERT_RPT'],
          [:global_merits, 'EVIDENCE_AMD_PLEADINGS'],
          [:global_merits, 'EVIDENCE_AMD_SOLICITOR_RPT'],
          [:global_merits, 'EVIDENCE_CA_CRIME_PROCS'],
          [:global_merits, 'EVIDENCE_CA_FINDING_FACT'],
          [:global_merits, 'EVIDENCE_CA_INJ_PSO'],
          [:global_merits, 'EVIDENCE_CA_POLICE_BAIL'],
          [:global_merits, 'EVIDENCE_CA_POLICE_CAUTION'],
          [:global_merits, 'EVIDENCE_CA_PROTECTIVE_INJ'],
          [:global_merits, 'EVIDENCE_CA_SOCSERV_ASSESS'],
          [:global_merits, 'EVIDENCE_CA_SOCSERV_LTTR'],
          [:global_merits, 'EVIDENCE_CA_UNSPENT_CONVICTION'],
          [:global_merits, 'EVIDENCE_COPY_PR_ORDER'],
          [:global_merits, 'EVIDENCE_DV_CONVICTION'],
          [:global_merits, 'EVIDENCE_DV_COURT_ORDER'],
          [:global_merits, 'EVIDENCE_DV_CRIM_PROCS_2A'],
          [:global_merits, 'EVIDENCE_DV_DVPN_2'],
          [:global_merits, 'EVIDENCE_DV_FIN_ABUSE'],
          [:global_merits, 'EVIDENCE_DV_FINDING_FACT_2A'],
          [:global_merits, 'EVIDENCE_DV_HEALTH_LETTER'],
          [:global_merits, 'EVIDENCE_DV_HOUSING_AUTHORITY'],
          [:global_merits, 'EVIDENCE_DV_IDVA'],
          [:global_merits, 'EVIDENCE_DV_IMMRULES_289A'],
          [:global_merits, 'EVIDENCE_DV_PARTY_ON_BAIL_2A'],
          [:global_merits, 'EVIDENCE_DV_POLICE_CAUTION_2A'],
          [:global_merits, 'EVIDENCE_DV_PROT_INJUNCT'],
          [:global_merits, 'EVIDENCE_DV_PUB_BODY'],
          [:global_merits, 'EVIDENCE_DV_PUBLIC_BODY'],
          [:global_merits, 'EVIDENCE_DV_REFUGE'],
          [:global_merits, 'EVIDENCE_DV_SUPP_SERVICE'],
          [:global_merits, 'EVIDENCE_DV_SUPPORT_ORG'],
          [:global_merits, 'EVIDENCE_DV_UNDERTAKING_2A'],
          [:global_merits, 'EVIDENCE_EXISTING_COUNSEL_OP'],
          [:global_merits, 'EVIDENCE_EXISTING_CT_ORDER'],
          [:global_merits, 'EVIDENCE_EXISTING_EXPERT_RPT'],
          [:global_merits, 'EVIDENCE_EXISTING_STATEMENT'],
          [:global_merits, 'EVIDENCE_EXPERT_REPORT'],
          [:global_merits, 'EVIDENCE_ICACU_LETTER'],
          [:global_merits, 'EVIDENCE_IQ_CORONER_CORR'],
          [:global_merits, 'EVIDENCE_IQ_COSTS_SCHEDULE'],
          [:global_merits, 'EVIDENCE_IQ_REPORT_ON_DEATH'],
          [:global_merits, 'EVIDENCE_LETTER_BEFORE_ACTION'],
          [:global_merits, 'EVIDENCE_MEDIATOR_APP7A'],
          [:global_merits, 'EVIDENCE_OMBUDSMAN_COMP_RPT'],
          [:global_merits, 'EVIDENCE_PLEADINGS_REQUIRED'],
          [:global_merits, 'EVIDENCE_PR_AGREEMENT'],
          [:global_merits, 'EVIDENCE_PRE_ACTION_DISCLOSURE'],
          [:global_merits, 'EVIDENCE_RELEVANT_CORR_ADR'],
          [:global_merits, 'EVIDENCE_RELEVANT_CORR_SETTLE'],
          [:global_merits, 'EVIDENCE_WARNING_LETTER'],
          [:global_merits, 'EXISTING_COUNSEL_OPINION'],
          [:global_merits, 'EXISTING_EXPERT_REPORTS'],
          [:global_merits, 'FH_LOWER_PROVIDED'],
          [:global_merits, 'HIGH_PROFILE'],
          [:global_merits, 'MENTAL_HEAL_ACT_MENTAL_CAP_ACT'],
          [:global_merits, 'MERITS_EVIDENCE_REQD'],
          [:global_merits, 'NEGOTIATION_CORRESPONDENCE'],
          [:global_merits, 'OTHER_PARTIES_MAY_BENEFIT'],
          [:global_merits, 'OTHERS_WHO_MAY_BENEFIT'],
          [:global_merits, 'PROCS_ARE_BEFORE_THE_COURT'],
          [:global_merits, 'UPLOAD_SEPARATE_STATEMENT'],
          [:global_merits, 'URGENT_FLAG'],
          [:opponent, 'OTHER_PARTY_PERSON'],
          [:opponent, 'PARTY_IS_A_CHILD'],
          [:opponent, 'RELATIONSHIP_CASE_AGENT'],
          [:opponent, 'RELATIONSHIP_CASE_BENEFICIARY'],
          [:opponent, 'RELATIONSHIP_CASE_CHILD'],
          [:opponent, 'RELATIONSHIP_CASE_GAL'],
          [:opponent, 'RELATIONSHIP_CASE_INT_PARTY'],
          [:opponent, 'RELATIONSHIP_CASE_INTERVENOR'],
          [:opponent, 'RELATIONSHIP_CHILD'],
          [:opponent, 'RELATIONSHIP_CIVIL_PARTNER'],
          [:opponent, 'RELATIONSHIP_CUSTOMER'],
          [:opponent, 'RELATIONSHIP_EMPLOYEE'],
          [:opponent, 'RELATIONSHIP_EMPLOYER'],
          [:opponent, 'RELATIONSHIP_EX_CIVIL_PARTNER'],
          [:opponent, 'RELATIONSHIP_EX_HUSBAND_WIFE'],
          [:opponent, 'RELATIONSHIP_GRANDPARENT'],
          [:opponent, 'RELATIONSHIP_HUSBAND_WIFE'],
          [:opponent, 'RELATIONSHIP_LANDLORD'],
          [:opponent, 'RELATIONSHIP_LEGAL_GUARDIAN'],
          [:opponent, 'RELATIONSHIP_LOCAL_AUTHORITY'],
          [:opponent, 'RELATIONSHIP_MEDICAL_PRO'],
          [:opponent, 'RELATIONSHIP_OTHER_FAM_MEMBER'],
          [:opponent, 'RELATIONSHIP_PARENT'],
          [:opponent, 'RELATIONSHIP_PROPERTY_OWNER'],
          [:opponent, 'RELATIONSHIP_SOL_BARRISTER'],
          [:opponent, 'RELATIONSHIP_STEP_PARENT'],
          [:opponent, 'RELATIONSHIP_SUPPLIER'],
          [:opponent, 'RELATIONSHIP_TENANT']
        ]
      end
    end
  end
end
