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
                 set_lead_proceeding: :da001,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider:,
                 office:,
                 percentage_home:)
        end
        let!(:proceeding) { legal_aid_application.reload.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let!(:chances_of_success) do
          create(:chances_of_success, :with_optional_text, proceeding:) unless skip_chance_of_success
        end
        let(:skip_chance_of_success) { false }

        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:cfe_result) { cfe_submission.cfe_result }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:applicant) { legal_aid_application.applicant }
        let(:percentage_home) { rand(1...99.0).round(2) }

        before do
          create(:cfe_v3_result, submission: cfe_submission)
          legal_aid_application.reload
        end

        describe "CAPSHARE_INPUT_C_11WP2_9A" do
          context "when the applicant has no plc shares" do
            before { savings_amount.update! plc_shares: nil }

            it "does not generate the block" do
              block = XmlExtractor.call(xml, :plc_shares, "CAPSHARE_INPUT_C_11WP2_9A")
              expect(block).not_to be_present
            end
          end

          context "when the applicant has plc shares" do
            before { savings_amount.update! plc_shares: 12_566 }

            it "generates the block" do
              block = XmlExtractor.call(xml, :plc_shares, "CAPSHARE_INPUT_C_11WP2_9A")
              expect(block).to have_currency_response 12_566.0
              expect(block).to be_user_defined
            end
          end
        end

        describe "LIFEASSUR_INPUT_C_13WP2_16A" do
          context "when the applicant has no life assurance policies" do
            before { savings_amount.update! life_assurance_endowment_policy: 0.0 }

            it "does not generate the block" do
              block = XmlExtractor.call(xml, :life_assurance, "LIFEASSUR_INPUT_C_13WP2_16A")
              expect(block).not_to be_present
            end
          end

          context "when the applicant has life assurance policies" do
            before { savings_amount.update! life_assurance_endowment_policy: 42_518.38 }

            it "generates the block" do
              block = XmlExtractor.call(xml, :life_assurance, "LIFEASSUR_INPUT_C_13WP2_16A")
              expect(block).to have_currency_response 42_518.38
              expect(block).to be_user_defined
            end
          end
        end

        describe "THIRDPARTACC_INPUT_C_8WP2_14A" do
          context "when the applicant has no access to other peoples accounts" do
            before { savings_amount.update! other_person_account: nil }

            it "does not generate the block" do
              block = XmlExtractor.call(xml, :third_party_acct, "THIRDPARTACC_INPUT_C_8WP2_14A")
              expect(block).not_to be_present
            end
          end

          context "when the applicant has access to other persons account" do
            before { savings_amount.update! other_person_account: 128.22 }

            it "generates the block" do
              block = XmlExtractor.call(xml, :third_party_acct, "THIRDPARTACC_INPUT_C_8WP2_14A")
              expect(block).to have_currency_response 128.22
              expect(block).to be_user_defined
            end
          end
        end

        describe "Timeshare" do
          context "when the applicant does not own timeshare" do
            before { other_assets_decl.update! timeshare_property_value: 0 }

            describe "TIMESHARE_INPUT_B_6WP2_22A" do
              it "does not generate the block" do
                block = XmlExtractor.call(xml, :timeshare, "TIMESHARE_INPUT_B_6WP2_22A")
                expect(block).not_to be_present
              end
            end

            describe "TIMESHARE_INPUT_C_6WP2_11A" do
              it "does not generate the block" do
                block = XmlExtractor.call(xml, :timeshare, "TIMESHARE_INPUT_C_6WP2_11A")
                expect(block).not_to be_present
              end
            end
          end

          context "when the applicant owns timeshare" do
            before { other_assets_decl.update! timeshare_property_value: 95_355.0 }

            describe "TIMESHARE_INPUT_B_6WP2_22A" do
              it "generates the block" do
                block = XmlExtractor.call(xml, :timeshare, "TIMESHARE_INPUT_B_6WP2_22A")
                expect(block).to have_boolean_response true
                expect(block).to be_user_defined
              end
            end

            describe "TIMESHARE_INPUT_C_6WP2_11A" do
              it "generates the block" do
                block = XmlExtractor.call(xml, :timeshare, "TIMESHARE_INPUT_C_6WP2_11A")
                expect(block).to have_currency_response 95_355
                expect(block).to be_user_defined
              end
            end
          end
        end

        describe "additional property" do
          context "when the applicant does not own additional property" do
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

            it "does not generate the blocks" do
              attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :additional_property, attr_name)
                expect(block).not_to be_present
              end
            end
          end

          context "when the applicant owns additional property" do
            before { other_assets_decl.update! second_home_value: 120_634, second_home_mortgage: 45_933 }

            context "when the applicant owns 100% of addtional property" do
              before { other_assets_decl.update! second_home_percentage: 100.0 }

              let(:attrs) do
                {
                  "ADDPROPERTY_INPUT_B_4WP2_16A" => false,
                  "ADDPROPERTY_INPUT_C_4WP2_13A" => 120_634,
                  "ADDPROPERTY_INPUT_C_4WP2_14A" => 45_933,
                  "ADDPROPERTY_INPUT_N_4WP2_22A" => 100.0,
                  "GB_INPUT_B_3WP2_29A" => true,
                }
              end

              it "generates attrs with expected values" do
                attrs.each do |attr_name, expected_value|
                  block = XmlExtractor.call(xml, :additional_property, attr_name)
                  case attr_name
                  when "ADDPROPERTY_INPUT_B_4WP2_16A", "GB_INPUT_B_3WP2_29A"
                    expect(block).to have_boolean_response expected_value
                  when "ADDPROPERTY_INPUT_N_4WP2_22A"
                    expect(block).to have_number_response expected_value
                  else
                    expect(block).to have_currency_response expected_value
                  end
                  expect(block).to be_user_defined
                end
              end
            end

            context "when the applicant shares ownership of additional property" do
              before { other_assets_decl.update! second_home_percentage: 50.0, second_home_mortgage: 0.0 }

              let(:attrs) do
                {
                  "ADDPROPERTY_INPUT_B_4WP2_16A" => true,
                  "ADDPROPERTY_INPUT_C_4WP2_13A" => 120_634,
                  "ADDPROPERTY_INPUT_C_4WP2_14A" => 0.0,
                  "ADDPROPERTY_INPUT_N_4WP2_22A" => 50.0,
                  "GB_INPUT_B_3WP2_29A" => true,
                }
              end

              it "generates attrs with expected values" do
                attrs.each do |attr_name, expected_value|
                  block = XmlExtractor.call(xml, :additional_property, attr_name)
                  case attr_name
                  when "ADDPROPERTY_INPUT_B_4WP2_16A", "GB_INPUT_B_3WP2_29A"
                    expect(block).to have_boolean_response expected_value
                  when "ADDPROPERTY_INPUT_N_4WP2_22A"
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

        describe "vehicle attributes" do
          # NOTE: Updated Sep 2023
          # These were originally populated because we were unsure if we needed to send _all_ available data so
          # so sent what we could.  We then realised that when we submit the means report, these fields were only
          # populating the CCMS means report.  These are now superfluous to the injection because we generate our
          # own means report and send it as PDF

          let(:vehicle) { legal_aid_application.vehicles.first }

          context "when the applicant has no vehicle" do
            before { vehicle.update! estimated_value: nil }

            let(:attrs) { %w[CARANDVEH_INPUT_B_14WP2_28A CARANDVEH_INPUT_C_14WP2_25A CARANDVEH_INPUT_C_14WP2_26A CARANDVEH_INPUT_D_14WP2_27A] }

            it "no longer generates the block" do
              attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :vehicle_entity, attr_name)
                expect(block).not_to be_present
              end
            end
          end

          context "when the applicant has vehicle" do
            before { vehicle.update! estimated_value: 6500, payment_remaining: 3215.66, more_than_three_years_old: true, used_regularly: regular_use }

            let(:regular_use) { true }

            describe "CARANDVEH_INPUT_B_14WP2_28A" do
              context "when in regular use" do
                let(:regular_use) { true }

                it "no longer generates the block" do
                  block = XmlExtractor.call(xml, :vehicle_entity, "CARANDVEH_INPUT_B_14WP2_28A")
                  expect(block).not_to be_present
                  # expect(block).to have_boolean_response false
                  # expect(block).to be_user_defined
                end
              end

              context "when not in regular use" do
                let(:regular_use) { false }

                it "no longer generates the block" do
                  block = XmlExtractor.call(xml, :vehicle_entity, "CARANDVEH_INPUT_B_14WP2_28A")
                  expect(block).not_to be_present
                  # expect(block).to have_boolean_response false
                  # expect(block).to be_user_defined
                end
              end
            end

            describe "CARANDVEH_INPUT_C_14WP2_25A current market value" do
              it "no longer generates the block" do
                block = XmlExtractor.call(xml, :vehicle_entity, "CARANDVEH_INPUT_C_14WP2_25A")
                expect(block).not_to be_present
                # expect(block).to have_currency_response 0.0
                # expect(block).to be_user_defined
              end
            end

            describe "CARANDVEH_INPUT_C_14WP2_26A - outstanding loan" do
              it "no longer generates the block" do
                block = XmlExtractor.call(xml, :vehicle_entity, "CARANDVEH_INPUT_C_14WP2_26A")
                expect(block).not_to be_present
                # expect(block).to have_currency_response 0.00
                # expect(block).to be_user_defined
              end
            end

            describe "CARANDVEH_INPUT_D_14WP2_27A - date_of_purchase" do
              it "no longer generates the block" do
                block = XmlExtractor.call(xml, :vehicle_entity, "CARANDVEH_INPUT_D_14WP2_27A")
                expect(block).not_to be_present
                # expect(block).to have_date_response Date.new(1970, 1, 1).strftime("%d-%m-%Y")
                # expect(block).to be_user_defined
              end
            end
          end
        end

        describe "NINO" do
          it "generates the national insurance number in means and merits" do
            %i[global_means global_merits].each do |entity|
              block = XmlExtractor.call(xml, entity, "NI_NO")
              expect(block).to have_text_response applicant.national_insurance_number
              expect(block).not_to be_user_defined
            end
          end
        end

        describe "PASSPORTED_NINO" do
          it "does not generate the block" do
            block = XmlExtractor.call(xml, :global_means, "PASSPORTED_NINO")
            expect(block).not_to be_present
          end
        end

        describe "GB_INPUT_B_9WP3_353A" do
          context "when the applicant has student finance" do
            before do
              legal_aid_application.applicant.update!(student_finance: true)
            end

            it "returns true" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP3_353A")
              expect(block).to have_boolean_response true
              expect(block).to be_user_defined
            end
          end

          context "when the applicant has no student finance" do
            before do
              legal_aid_application.applicant.update!(student_finance: false)
            end

            it "returns false" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_9WP3_353A")
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "GB_INPUT_C_6WP3_323A" do
          it "no pension is declared so it does not generate a block" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_C_6WP3_323A")
            expect(block).not_to be_present
          end
        end

        describe "gross income" do
          let!(:friends_or_family) { create(:transaction_type, :credit, :friends_or_family) }
          let!(:property_or_lodger) { create(:transaction_type, :credit, name: "property_or_lodger") }
          let(:maintenance_in) { create(:transaction_type, :credit, name: "maintenance_in") }
          let(:benefits) { create(:transaction_type, :credit, name: "benefits") }
          let(:bank_account) { create(:bank_account, bank_provider:) }
          let(:bank_provider) { create(:bank_provider, applicant:) }
          let(:benefits_bank_transaction) { create(:bank_transaction, :credit, transaction_type: benefits, bank_account:) }
          let(:applicant) { create(:applicant, :with_address) }
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
                   office:,
                   applicant:,
                   transaction_types: [benefits])
          end

          describe "GB_INPUT_B_8WP3_310A" do
            context "when the applicant receives financial support" do
              before { create(:bank_transaction, :credit, transaction_type: friends_or_family, bank_account:) }

              it "generates a block with the correct values" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_8WP3_310A")
                expect(block).to have_boolean_response true
                expect(block).to be_user_defined
              end
            end

            context "when the applicant does not receive financial support" do
              it "generates a block with a response of false" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_8WP3_310A")
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          describe "rental income" do
            context "when the applicant receives rental income" do
              before { create(:bank_transaction, :credit, transaction_type: property_or_lodger, bank_account:) }

              let(:expected_results) do
                [
                  ["GB_INPUT_B_9WP3_351A", false],
                  ["GB_INPUT_B_9WP3_352A", false],
                ]
              end

              it "generates a block with a response of false" do
                expected_results.each do |expected_result_array|
                  attr_name, expected_result = expected_result_array
                  block = XmlExtractor.call(xml, :global_means, attr_name)
                  expect(block).to have_boolean_response expected_result
                  expect(block).to be_user_defined
                end
              end
            end

            context "when the applicant does not receive rental income" do
              let(:expected_results) do
                [
                  ["GB_INPUT_B_9WP3_351A", false],
                  ["GB_INPUT_B_9WP3_352A", false],
                ]
              end

              it "generates a block with a response of false" do
                expected_results.each do |expected_result_array|
                  attr_name, expected_result = expected_result_array
                  block = XmlExtractor.call(xml, :global_means, attr_name)
                  expect(block).to have_boolean_response expected_result
                  expect(block).to be_user_defined
                end
              end
            end
          end

          describe "maintenance payments" do
            subject(:block) { XmlExtractor.call(xml, :global_means, attribute) }

            describe "are received by the applicant" do
              before do
                cfe_submission.result.destroy!
                create(:cfe_v3_result, :with_maintenance_received, submission: cfe_submission)
              end

              describe "GB_INPUT_C_8WP3_303A" do
                let(:attribute) { "GB_INPUT_C_8WP3_303A" }

                it "generates a block with the correct values" do
                  expect(block).to have_number_response "150.00"
                  expect(block).to be_user_defined
                end
              end

              describe "GB_INPUT_B_8WP3_308A" do
                let(:attribute) { "GB_INPUT_B_8WP3_308A" }

                it "generates a block with the correct values" do
                  expect(block).to have_boolean_response true
                  expect(block).to be_user_defined
                end
              end
            end

            describe "are not received by the applicant" do
              describe "GB_INPUT_C_8WP3_303A" do
                let(:attribute) { "GB_INPUT_C_8WP3_303A" }

                it "does not generate a block" do
                  expect(block).not_to be_present
                end
              end

              describe "GB_INPUT_B_8WP3_308A" do
                let(:attribute) { "GB_INPUT_B_8WP3_308A" }

                it "generates a block with the correct values" do
                  expect(block).to have_boolean_response false
                  expect(block).to be_user_defined
                end
              end
            end
          end
        end

        describe "GB_INPUT_B_13WP3_14A" do
          context "when the applicant pays rent or mortgage" do
            let(:rent_or_mortgage_payment) { create(:transaction_type, :debit, name: "rent_or_mortgage") }
            let(:attrs) do
              %w[
                GB_INPUT_B_13WP3_14A
                GB_INPUT_B_13WP3_1A
                GB_INPUT_B_13WP3_36A
              ]
            end

            before do
              create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: rent_or_mortgage_payment)
            end

            it "returns true" do
              attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :global_means, attr_name)
                expect(block).to have_boolean_response true
                expect(block).not_to be_user_defined
              end
            end

            context "when the applicant does not pay rent or mortgage" do
              before { legal_aid_application.transaction_types.delete_all }

              let(:attrs) do
                %w[
                  GB_INPUT_B_13WP3_14A
                  GB_INPUT_B_13WP3_1A
                  GB_INPUT_B_13WP3_36A
                ]
              end

              it "returns false" do
                attrs.each do |attr_name|
                  block = XmlExtractor.call(xml, :global_means, attr_name)
                  expect(block).to have_boolean_response false
                  expect(block).not_to be_user_defined
                end
              end
            end
          end
        end

        describe "GB_INPUT_C_13WP3_3A" do
          context "when the applicant pays a mortgage" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result, submission: cfe_submission)
              create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: rent_or_mortgage_payment)
            end

            let(:rent_or_mortgage_payment) { create(:transaction_type, :debit, name: "rent_or_mortgage") }

            it "does generate the block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_C_13WP3_3A")
              expect(block).to have_currency_response 125.00
              expect(block).to be_present
            end
          end

          context "when the applicant does not pay a mortgage" do
            before { legal_aid_application.transaction_types.delete_all }

            it "does not generate the block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_C_13WP3_3A")
              expect(block).not_to be_present
            end
          end
        end

        describe "PUI_CLIENT_INCOME_CONT" do
          context "when the applicant has to make an income contribution" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result, :with_income_contribution_required, submission: cfe_submission)
            end

            it "returns the expected values" do
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_INCOME_CONT")
              expect(block).to have_currency_response 366.82
              expect(block).not_to be_user_defined
            end
          end

          context "when the applicant does not have to make an income contribution" do
            it "returns no block" do
              block = XmlExtractor.call(xml, :global_means, "PUI_CLIENT_INCOME_CONT")
              expect(block).to be_present
              expect(block).to have_currency_response 0.0
            end
          end
        end

        describe "OUT_INCOME_CONT" do
          context "when the applicant has to make an income contribution" do
            before do
              cfe_submission.result.destroy!
              create(:cfe_v3_result, :with_income_contribution_required, submission: cfe_submission)
            end

            it "returns the expected values" do
              block = XmlExtractor.call(xml, :global_means, "OUT_INCOME_CONT")
              expect(block).to have_currency_response 366.82
              expect(block).not_to be_user_defined
            end
          end

          context "when the applicant does not have to make an income contribution" do
            it "returns no block" do
              block = XmlExtractor.call(xml, :global_means, "OUT_INCOME_CONT")
              expect(block).to be_present
              expect(block).to have_currency_response 0.0
            end
          end
        end

        describe "LAND_INPUT_B_5WP2_26A" do
          subject(:block) { XmlExtractor.call(xml, :global_means, "LAND_INPUT_B_5WP2_26A") }

          context "when the applicant owns land" do
            it "generates the block" do
              expect(block).to have_boolean_response true
              expect(block).to be_user_defined
            end
          end

          context "when the applicant does not own land" do
            before { legal_aid_application.other_assets_declaration.land_value = 0.0 }

            it "does not generate the block" do
              expect(block).to have_boolean_response false
            end
          end
        end

        describe "LAND_INPUT_C_5WP2_13A" do
          subject(:block) { XmlExtractor.call(xml, :global_means, "LAND_INPUT_C_5WP2_13A") }

          before { legal_aid_application.other_assets_declaration.land_value = land_value }

          context "when the applicant owns land" do
            let(:land_value) { 4567.00 }

            it "generates the block" do
              expect(block).to have_currency_response 4567.00
              expect(block).to be_user_defined
            end
          end

          context "when the applicant does not own land" do
            let(:land_value) { 0.0 }

            it "does not generate the block" do
              expect(block).not_to be_present
            end
          end
        end

        describe "MONEYDUE_INPUT_C_15WP2_14A" do
          subject(:block) { XmlExtractor.call(xml, :global_means, "MONEYDUE_INPUT_C_15WP2_14A") }

          before { legal_aid_application.other_assets_declaration.money_owed_value = money_owed }

          context "when the applicant has money owed to them" do
            let(:money_owed) { 4567.00 }

            it "generates the block" do
              expect(block).to have_currency_response 4567.00
              expect(block).to be_user_defined
            end
          end

          context "when the applicant does not have money owed" do
            let(:money_owed) { 0.0 }

            it "does not generate the block" do
              expect(block).not_to be_present
            end
          end
        end

        describe "PROSPECTS_OF_SUCCESS" do
          subject(:block) { XmlExtractor.call(xml, :global_means, "PROSPECTS_OF_SUCCESS") }

          examples = [
            { input: "likely", result: "FM" },
            { input: "marginal", result: "FO" },
            { input: "poor", result: "NE" },
            { input: "borderline", result: "FH" },
            { input: "not_known", result: "FJ" },
          ].freeze

          examples.each do |test|
            context "when it is set to #{test[:input]}" do
              before { chances_of_success.update! success_prospect: test[:input] }

              it { is_expected.to have_text_response test[:result] }
              it { is_expected.not_to be_user_defined }
            end
          end
        end

        describe "MONEYDUE_INPUT_T_15WP2_15A" do
          subject(:block) { XmlExtractor.call(xml, :global_means, "MONEYDUE_INPUT_T_15WP2_15A") }

          before { legal_aid_application.other_assets_declaration.money_owed_value = money_owed }

          context "when the applicant has money owed to them" do
            let(:money_owed) { 4567.00 }

            it "generates the block" do
              expect(block).to have_text_response "Other"
              expect(block).to be_user_defined
            end
          end

          context "when the applicant does not have money owed" do
            let(:money_owed) { 0.0 }

            it "does not generate the block" do
              expect(block).not_to be_present
            end
          end
        end

        describe "shared ownership attributes" do
          examples = [
            {
              input: 60,
              tests: [
                { attributes: %w[GB_INPUT_B_3WP2_10A GB_INPUT_B_3WP2_8A], result: true },
                { attributes: %w[GB_INPUT_N_3WP2_14A], result: 60.0 },
                { attributes: %w[MAINTHIRD_INPUT_N_3WP2_11A], result: 40.0 },
              ],
            },
            {
              input: 99,
              tests: [
                { attributes: %w[GB_INPUT_B_3WP2_10A GB_INPUT_B_3WP2_8A], result: true },
                { attributes: %w[GB_INPUT_N_3WP2_14A], result: 99.0 },
                { attributes: %w[MAINTHIRD_INPUT_N_3WP2_11A], result: 1.0 },
              ],
            },
            {
              input: 100,
              tests: [
                { attributes: %w[GB_INPUT_B_3WP2_10A GB_INPUT_B_3WP2_8A], result: false },
                { attributes: %w[GB_INPUT_N_3WP2_14A], omit_block: true },
                { attributes: %w[MAINTHIRD_INPUT_N_3WP2_11A], omit_block: true },
              ],
            },
          ].freeze
          examples.each do |example|
            example[:tests].each do |test|
              test[:attributes].each do |attribute|
                context attribute.to_s do
                  subject(:block) { XmlExtractor.call(xml, :global_means, attribute) }

                  let(:true_false) { [true, false] }
                  let(:percentage_home) { example[:input] }

                  it "returns #{test[:result]} when percentage_home is set to #{test[:input]}" do
                    if test[:omit_block]
                      expect(block).not_to be_present
                    elsif true_false.include? test[:result]
                      expect(block).to have_boolean_response test[:result]
                    else
                      expect(block).to have_number_response test[:result]
                    end
                  end
                end
              end
            end
          end

          describe "GB_INPUT_B_3WP2_27A" do
            subject(:block) { XmlExtractor.call(xml, :global_means, "GB_INPUT_B_3WP2_27A") }

            before { legal_aid_application.own_home = ownership }

            context "when ownership of main dwelling is declared in capital" do
              context "with outright ownership" do
                let(:ownership) { "owned_outright" }

                it "generates the block" do
                  expect(block).to have_boolean_response true
                  expect(block).to be_user_defined
                end
              end

              context "with a mortgage" do
                let(:ownership) { "mortgage" }

                it "generates the block" do
                  expect(block).to have_boolean_response true
                  expect(block).to be_user_defined
                end
              end
            end

            context "when ownership of main dwelling is not declared in capital" do
              let(:ownership) { "no" }

              it "generates the block" do
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          describe "GB_INPUT_C_3WP2_5A" do
            subject(:block) { XmlExtractor.call(xml, :global_means, "GB_INPUT_C_3WP2_5A") }

            before { legal_aid_application.update(own_home: ownership, property_value: 55_123.00) }

            context "when ownership of main dwelling is declared in capital" do
              context "with outright ownership" do
                let(:ownership) { "owned_outright" }

                it "generates the block" do
                  expect(block).to have_currency_response 55_123.00
                  expect(block).to be_user_defined
                end
              end

              context "with a mortgage" do
                let(:ownership) { "mortgage" }

                it "generates the block" do
                  expect(block).to have_currency_response 55_123.00
                  expect(block).to be_user_defined
                end
              end
            end

            context "when ownership of main dwelling is not declared in capital" do
              let(:ownership) { "no" }

              it "does not generate the block" do
                expect(block).not_to be_present
              end
            end
          end

          describe "GB_INPUT_C_3WP2_7A" do
            subject(:block) { XmlExtractor.call(xml, :global_means, "GB_INPUT_C_3WP2_7A") }

            before { legal_aid_application.update(own_home: ownership, property_value: 55_123.00, outstanding_mortgage_amount: 25_432.00) }

            context "when ownership of main dwelling is declared in capital" do
              context "with outright ownership" do
                let(:ownership) { "owned_outright" }

                it "does not generate the block" do
                  expect(block).not_to be_present
                end
              end

              context "with a mortgage" do
                let(:ownership) { "mortgage" }

                it "generates the block" do
                  expect(block).to have_currency_response 25_432.00
                  expect(block).to be_user_defined
                end
              end
            end

            context "when ownership of main dwelling is not declared in capital" do
              let(:ownership) { "no" }

              it "does not generate the block" do
                expect(block).not_to be_present
              end
            end
          end
        end
      end
    end
  end
end
