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
        let(:applicant) { legal_aid_application.applicant }

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

        context 'CAPSHARE_INPUT_C_11WP2_9A' do
          context 'applicant has no plc shares' do
            before { savings_amount.update! plc_shares: nil }
            it 'does not generate the block' do
              block = XmlExtractor.call(xml, :plc_shares, 'CAPSHARE_INPUT_C_11WP2_9A')
              expect(block).not_to be_present
            end
          end

          context 'applicant has plc shares' do
            before { savings_amount.update! plc_shares: 12_566 }
            it 'generates the block' do
              block = XmlExtractor.call(xml, :plc_shares, 'CAPSHARE_INPUT_C_11WP2_9A')
              expect(block).to have_currency_response 12_566.0
              expect(block).to be_user_defined
            end
          end
        end

        context 'LIFEASSUR_INPUT_C_13WP2_16A' do
          context 'applicant has no life assurance policies' do
            before { savings_amount.update! life_assurance_endowment_policy: 0.0 }
            it 'does not generate the block' do
              block = XmlExtractor.call(xml, :life_assurance, 'LIFEASSUR_INPUT_C_13WP2_16A')
              expect(block).not_to be_present
            end
          end

          context 'applicant has life assurance policies' do
            before { savings_amount.update! life_assurance_endowment_policy: 42_518.38 }
            it 'generates the block' do
              block = XmlExtractor.call(xml, :life_assurance, 'LIFEASSUR_INPUT_C_13WP2_16A')
              expect(block).to have_currency_response 42_518.38
              expect(block).to be_user_defined
            end
          end
        end

        context 'THIRDPARTACC_INPUT_C_8WP2_14A' do
          context 'applicant has no access to other peoples accounts' do
            before { savings_amount.update! other_person_account: nil }
            it 'does not generate the block' do
              block = XmlExtractor.call(xml, :third_party_acct, 'THIRDPARTACC_INPUT_C_8WP2_14A')
              expect(block).not_to be_present
            end
          end

          context 'applicant has access to other persons account' do
            before { savings_amount.update! other_person_account: 128.22 }
            it 'generates the block' do
              block = XmlExtractor.call(xml, :third_party_acct, 'THIRDPARTACC_INPUT_C_8WP2_14A')
              expect(block).to have_currency_response 128.22
              expect(block).to be_user_defined
            end
          end
        end

        context 'Timeshare' do
          context 'Applicant does not own timeshare' do
            before { other_assets_decl.update! timeshare_property_value: 0 }
            context 'TIMESHARE_INPUT_B_6WP2_22A' do
              it 'does not generate the block' do
                block = XmlExtractor.call(xml, :timeshare, 'TIMESHARE_INPUT_B_6WP2_22A')
                expect(block).not_to be_present
              end
            end

            context 'TIMESHARE_INPUT_C_6WP2_11A' do
              it 'does not generate the block' do
                block = XmlExtractor.call(xml, :timeshare, 'TIMESHARE_INPUT_C_6WP2_11A')
                expect(block).not_to be_present
              end
            end
          end

          context 'applicant owns timeshare' do
            before { other_assets_decl.update! timeshare_property_value: 95_355.0 }
            context 'TIMESHARE_INPUT_B_6WP2_22A' do
              it 'generates the block' do
                block = XmlExtractor.call(xml, :timeshare, 'TIMESHARE_INPUT_B_6WP2_22A')
                expect(block).to have_boolean_response true
                expect(block).to be_user_defined
              end
            end

            context 'TIMESHARE_INPUT_C_6WP2_11A' do
              it 'generates the block' do
                block = XmlExtractor.call(xml, :timeshare, 'TIMESHARE_INPUT_C_6WP2_11A')
                expect(block).to have_currency_response 95_355
                expect(block).to be_user_defined
              end
            end
          end
        end

        context 'additional property' do
          context 'applicant does not own additional property' do
            before { other_assets_decl.update! second_home_value: nil }
            let(:attrs) do
              %w[
                ADDPROPERTY_INPUT_B_4WP2_16A
                ADDPROPERTY_INPUT_C_4WP2_13A
                ADDPROPERTY_INPUT_C_4WP2_14A
                ADDPROPERTY_INPUT_N_4WP2_22A
                GB_INPUT_B_3WP2_29A
              ]
            end
            it 'does not generate the blocks' do
              attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :additional_property, attr_name)
                expect(block).not_to be_present
              end
            end
          end

          context 'applicant owns additional property' do
            before { other_assets_decl.update! second_home_value: 120_634, second_home_mortgage: 45_933 }
            context 'applicant owns 100% of addtional property' do
              before { other_assets_decl.update! second_home_percentage: 100.0 }
              let(:attrs) do
                {
                  'ADDPROPERTY_INPUT_B_4WP2_16A' => false,
                  'ADDPROPERTY_INPUT_C_4WP2_13A' => 120_634,
                  'ADDPROPERTY_INPUT_C_4WP2_14A' => 45_933,
                  'ADDPROPERTY_INPUT_N_4WP2_22A' => 100.0,
                  'GB_INPUT_B_3WP2_29A' => true
                }
              end
              it 'generates attrs with expected values' do
                attrs.each do |attr_name, expected_value|
                  block = XmlExtractor.call(xml, :additional_property, attr_name)
                  case attr_name
                  when 'ADDPROPERTY_INPUT_B_4WP2_16A', 'GB_INPUT_B_3WP2_29A'
                    expect(block).to have_boolean_response expected_value
                  when 'ADDPROPERTY_INPUT_N_4WP2_22A'
                    expect(block).to have_number_response expected_value
                  else
                    expect(block).to have_currency_response expected_value
                  end
                  expect(block).to be_user_defined
                end
              end
            end

            context 'applicant shares ownership of additional property' do
              before { other_assets_decl.update! second_home_percentage: 50.0, second_home_mortgage: 0.0 }
              let(:attrs) do
                {
                  'ADDPROPERTY_INPUT_B_4WP2_16A' => true,
                  'ADDPROPERTY_INPUT_C_4WP2_13A' => 120_634,
                  'ADDPROPERTY_INPUT_C_4WP2_14A' => 0.0,
                  'ADDPROPERTY_INPUT_N_4WP2_22A' => 50.0,
                  'GB_INPUT_B_3WP2_29A' => true
                }
              end
              it 'generates attrs with expected values' do
                attrs.each do |attr_name, expected_value|
                  block = XmlExtractor.call(xml, :additional_property, attr_name)
                  case attr_name
                  when 'ADDPROPERTY_INPUT_B_4WP2_16A', 'GB_INPUT_B_3WP2_29A'
                    expect(block).to have_boolean_response expected_value
                  when 'ADDPROPERTY_INPUT_N_4WP2_22A'
                    expect(block).to have_number_response expected_value
                  else
                    expect(block).to have_currency_response expected_value
                  end
                  expect(block).to be_user_defined
                end
              end
            end
          end
        end

        context 'vehicle attributes' do
          let(:vehicle) { legal_aid_application.vehicle }
          context 'applicant has no vehicle' do
            before { vehicle.update! estimated_value: nil }
            let(:attrs) { %w[CARANDVEH_INPUT_B_14WP2_28A CARANDVEH_INPUT_C_14WP2_25A CARANDVEH_INPUT_C_14WP2_26A CARANDVEH_INPUT_D_14WP2_27] }
            it 'does not generate the attributes' do
              attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :vehicle_entity, attr_name)
                expect(block).not_to be_present
              end
            end
          end

          context 'applicant has vehicle' do
            before { vehicle.update! estimated_value: 6500, payment_remaining: 3215.66, purchased_on: 5.years.ago.to_date, used_regularly: regular_use }
            let(:regular_use) { true }

            context 'CARANDVEH_INPUT_B_14WP2_28A In regular use?' do
              context 'in regular use' do
                let(:regular_use) { true }
                it 'generates the block with a value of true' do
                  block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_B_14WP2_28A')
                  expect(block).to have_boolean_response true
                  expect(block).to be_user_defined
                end
              end

              context 'not in regular use' do
                let(:regular_use) { false }
                it 'generates the block with a value of true' do
                  block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_B_14WP2_28A')
                  expect(block).to have_boolean_response false
                  expect(block).to be_user_defined
                end
              end
            end

            context 'CARANDVEH_INPUT_C_14WP2_25A current market value' do
              it 'generates the block with the correct value' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_C_14WP2_25A')
                expect(block).to have_currency_response 6500.0
                expect(block).to be_user_defined
              end
            end

            context 'CARANDVEH_INPUT_C_14WP2_26A - outstanding loan' do
              it 'generates the block with the correct value' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_C_14WP2_26A')
                expect(block).to have_currency_response 3215.66
                expect(block).to be_user_defined
              end
            end

            context 'CARANDVEH_INPUT_D_14WP2_27A - date_of_purchase' do
              it 'generates the block with the correct value' do
                block = XmlExtractor.call(xml, :vehicle_entity, 'CARANDVEH_INPUT_D_14WP2_27A')
                expect(block).to have_date_response 5.years.ago.strftime('%d-%m-%Y')
                expect(block).to be_user_defined
              end
            end
          end
        end

        context 'NINO' do
          it 'generates the national insurance number in means and merits' do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, 'NI_NO')
              expect(block).to have_text_response applicant.national_insurance_number
              expect(block).not_to be_user_defined
            end
          end
        end

        context 'gross income' do
          let!(:friends_or_family) { create :transaction_type, :credit, :friends_or_family }
          let(:benefits) { create :transaction_type, :credit, name: 'benefits' }
          let(:bank_account) { create :bank_account, bank_provider: bank_provider }
          let(:bank_provider) { create :bank_provider, applicant: applicant }
          let(:bank_account) { create :bank_account, bank_provider: bank_provider }
          let!(:benefits_bank_transaction) { create :bank_transaction, :credit, transaction_type: benefits, bank_account: bank_account }
          let(:applicant) { create :applicant, :with_address }
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
                   office: office,
                   applicant: applicant,
                   transaction_types: [benefits]
          end

          context 'GB_INPUT_B_8WP3_310A' do
            context 'when the applicant receives financial support' do
              before { create :bank_transaction, :credit, transaction_type: friends_or_family, bank_account: bank_account }

              it 'generates generates a block with the correct values' do
                block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_8WP3_310A')
                expect(block).to have_boolean_response true
                expect(block).to be_user_defined
              end
            end

            context 'when the applicant does not receive financial support' do
              it 'generates does not generate a block' do
                block = XmlExtractor.call(xml, :global_means, 'GB_INPUT_B_8WP3_310A')
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end
        end
      end
    end
  end
end
