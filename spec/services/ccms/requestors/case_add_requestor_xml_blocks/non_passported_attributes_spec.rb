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
                 :with_non_passported_state_machine,
                 :submitting_assessment,
                 :with_merits_submitted,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider:,
                 office:)
        end

        let!(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
        let(:opponent) { legal_aid_application.opponent }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:success_prospect) { :likely }
        let(:timestamp) { Time.current.strftime("%Y-%m-%d_%H.%M") }
        let(:applicant) { legal_aid_application.applicant }
        let(:default_cost) { legal_aid_application.lead_proceeding.substantive_cost_limitation }

        before do
          create(:chances_of_success, :with_optional_text, proceeding:)
          create(:cfe_v3_result, submission: cfe_submission)
        end

        # uncomment this example to create a file of the payload for manual inspection
        # it 'create example payload file' do
        #   filename = Rails.root.join('tmp/generated_non_means_tested_ccms_payload.xml')
        #   File.open(filename, 'w') { |f| f.puts xml }
        #   expect(File.exist?(filename)).to be true
        # end

        describe "hard coded false attributes" do
          it "generates the block with boolean value set to false" do
            false_attributes.each do |config_spec|
              entity, attribute, user_defined_ind = config_spec
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response(false)

              if user_defined_ind == true
                expect(block).to be_user_defined
              else
                expect(block).to not_be_user_defined
              end
            end
          end
        end

        describe "hard coded true attributes" do
          it "generates the block with boolean value set to false" do
            true_attributes.each do |config_spec|
              entity, attribute, user_defined_ind = config_spec

              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).to have_boolean_response true
              if user_defined_ind == true
                expect(block).to be_user_defined
              else
                expect(block).to not_be_user_defined
              end
            end
          end
        end

        describe "attributes in ADDPROPERTY entity" do
          before { legal_aid_application.other_assets_declaration.update! second_home_value: 244_000 }

          it "generates all the attributes as false" do
            additional_property_false_attrs.each do |attr_pair|
              attr_name, user_defined = attr_pair
              block = XmlExtractor.call(xml, :additional_property, attr_name)
              expect(block).to have_boolean_response false
              if user_defined == true
                expect(block).to be_user_defined
              else
                expect(block).to not_be_user_defined
              end
            end
          end
        end

        describe "attributes in bank_acct entity" do
          it "generates each of the attributes as false for each bank account" do
            instances = %i[first_bank_acct_instance second_bank_acct_instance]
            instances.each do |instance|
              bank_acct_false_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, instance, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end
        end

        describe "attributes in vehicles entity" do
          it "generates each attribute as false" do
            vehicle_false_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :vehicle_entity, attr_name)
              expect(block).not_to be_present
            end
          end
        end

        describe "attributes in CLICAPITAL entity" do
          it "generates each attribute as false" do
            cli_capital_false_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :cli_capital, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "premium bond attributes in CLIPREMIUM entity" do
          it "generates each attribute as false" do
            premium_bond_false_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :cli_premium, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "stocks attributes in CLIPREMIUM entity" do
          it "generates each attribute as false" do
            stocks_false_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :cli_stock, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "global means main dwelling attribute" do
          context "when the applicant does not own main home" do
            before { legal_aid_application.update! own_home: "no" }

            it "omits all the attributes" do
              global_means_main_dwelling_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :global_means, attr_name)
                expect(block).not_to be_present
              end
            end
          end

          context "when the applicant owns main home outright" do
            before { legal_aid_application.update! own_home: "owned_outright" }

            it "generates all the attributes as false" do
              global_means_main_dwelling_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :global_means, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the applicant owns main home with a mortgage" do
            before { legal_aid_application.update! own_home: "mortgage" }

            it "generates all the attributes as false" do
              global_means_main_dwelling_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :global_means, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the conditionally present 'land' attribute is set" do
            context "and applicant has land" do
              it "inserts attrs into the payload with false" do
                conditional_land_attrs.each do |attr_name|
                  block = XmlExtractor.call(xml, :land, attr_name)
                  expect(block).to have_boolean_response false
                  expect(block).to be_user_defined
                end
              end
            end

            context "and applicant has no land" do
              before { legal_aid_application.other_assets_declaration.update! land_value: 0 }

              it "does not insert attrs into the payload" do
                conditional_land_attrs.each do |attr_name|
                  block = XmlExtractor.call(xml, :land, attr_name)
                  expect(block).not_to be_present
                end
              end
            end
          end
        end

        describe "Life assurance attributes" do
          it "generates attributes" do
            life_assurance_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :life_assurance, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "money due attributes" do
          context "when the applicant has money due" do
            it "generates attributes" do
              money_due_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :money_due, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the applicant has no money due" do
            before { legal_aid_application.other_assets_declaration.update! money_owed_value: nil }

            it "does not generate the attributes" do
              money_due_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :money_due, attr_name)
                expect(block).not_to be_present
              end
            end
          end
        end

        describe "third party account attrs" do
          it "generates attributes" do
            third_party_acct_attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :third_party_acct, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "conditional timeshare attrs" do
          context "when the applicant owns timeshare" do
            it "generates the attributes" do
              conditional_timeshare_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :timeshare, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the applicant does not have timeshare" do
            before { legal_aid_application.other_assets_declaration.update! timeshare_property_value: 0.0 }

            it "does not generate the attributes" do
              conditional_timeshare_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :timeshare, attr_name)
                expect(block).not_to be_present
              end
            end
          end
        end

        describe "conditional trust attributes" do
          context "when the applicant has a trust" do
            it "generates the attributes" do
              conditional_trust_attributes.each do |attr_name|
                block = XmlExtractor.call(xml, :trust, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the applicant doest not have a trust" do
            before { legal_aid_application.other_assets_declaration.update! trust_value: nil }

            it "does not generate the attributes" do
              conditional_trust_attributes.each do |attr_name|
                block = XmlExtractor.call(xml, :trust, attr_name)
                expect(block).not_to be_present
              end
            end
          end
        end

        describe "conditional valuable possessions attributes" do
          context "when the applicant has valuable possessions" do
            before { other_assets_decl.update! valuable_items_value: 878_787 }

            it "generates the attributes" do
              conditional_valuable_possessions_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :valuable_possessions, attr_name)
                expect(block).to have_boolean_response false
                expect(block).to be_user_defined
              end
            end
          end

          context "when the applicant does not have valuable possessions" do
            before { other_assets_decl.update! valuable_items_value: nil }

            it "goes not generate the attributes" do
              conditional_valuable_possessions_attrs.each do |attr_name|
                block = XmlExtractor.call(xml, :valuable_possessions, attr_name)
                expect(block).not_to be_present
              end
            end
          end
        end

        describe "global means outgoing attributes" do
          context "when there are maintenance payments" do
            let(:maintenance_transaction) { create(:transaction_type, :debit, name: "maintenance_out") }

            before do
              create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: maintenance_transaction)
            end

            it "has attributes" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_12WP3_3A")
              expect(block).to have_boolean_response true
              expect(block).to be_user_defined
            end

            context "when there are no payments" do
              before { legal_aid_application.transaction_types.delete_all }

              it "does not have attributes" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_12WP3_3A")
                expect(block).to have_boolean_response false
              end
            end
          end

          context "when the applicant has criminal legal aid payments" do
            let(:criminal_legal_aid_transaction) { create(:transaction_type, :debit, name: "legal_aid") }

            before do
              create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: criminal_legal_aid_transaction)
            end

            it "has attributes" do
              block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_14WP3_1A")
              expect(block).to have_boolean_response true
              expect(block).to be_user_defined
            end

            context "when there are no payments" do
              before { legal_aid_application.transaction_types.delete_all }

              it "does not have attributes" do
                block = XmlExtractor.call(xml, :global_means, "GB_INPUT_B_14WP3_1A")
                expect(block).to have_boolean_response false
              end
            end
          end

          context "when there are childcare payments" do
            let(:childcare_out) { create(:transaction_type, :debit, name: "child_care") }

            before do
              create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: childcare_out)
            end

            it "has attribute block" do
              block = XmlExtractor.call(xml, :global_means, "GB_INFER_B_12WP3_12A")
              expect(block).to have_boolean_response true
              expect(block).to be_user_defined
            end

            context "when there are no childcare payments" do
              before { legal_aid_application.transaction_types.delete_all }

              it "does not have attribute block" do
                block = XmlExtractor.call(xml, :global_means, "GB_INFER_B_12WP3_12A")
                expect(block).to have_boolean_response false
              end
            end
          end
        end

        describe "attributes for WILL" do
          it "generates the attributes" do
            will_attributes.each do |attr_name|
              block = XmlExtractor.call(xml, :will, attr_name)
              expect(block).to have_boolean_response false
              expect(block).to be_user_defined
            end
          end
        end

        describe "CERTIFICATE_PREDICTED_COSTS - estimated costs" do
          it "generates the block with the right value" do
            block = XmlExtractor.call(xml, :global_merits, "CERTIFICATE_PREDICTED_COSTS")
            expect(block).to have_currency_response 25_000.0
            expect(block).not_to be_user_defined
          end
        end

        describe "URGENT_APPLICATION_TAG" do
          it "generates the block with the right value" do
            block = XmlExtractor.call(xml, :global_merits, "URGENT_APPLICATION_TAG")
            expect(block).to have_text_response "Non Urgent"
            expect(block).not_to be_user_defined
          end
        end

        describe "COUNSEL_FEE_FAMILY" do
          it "generates the block with the right value" do
            block = XmlExtractor.call(xml, :proceeding_merits, "COUNSEL_FEE_FAMILY")
            expect(block).to have_currency_response 0.0
            expect(block).to be_user_defined
          end
        end

        describe "CHILD_CLIENT" do
          let(:sixteen_today) { 16.years.ago.to_date }
          let(:sixteen_yesterday) { sixteen_today - 1.day }
          let(:sixteen_tomorrow) { sixteen_today + 1.day }

          before { applicant.update! date_of_birth: dob }

          context "when the applicant is 16 today" do
            let(:dob) { sixteen_today }

            it "generates the block as an adult" do
              block = XmlExtractor.call(xml, :global_merits, "CHILD_CLIENT")
              expect(block).to have_boolean_response false
              expect(block).not_to be_user_defined
            end
          end

          context "when the applicant is 16 tomorrow" do
            let(:dob) { sixteen_tomorrow }

            it "generates the block as a child" do
              block = XmlExtractor.call(xml, :global_merits, "CHILD_CLIENT")
              expect(block).to have_boolean_response true
              expect(block).not_to be_user_defined
            end
          end

          context "when the applicant was 16 yesterday" do
            let(:dob) { sixteen_yesterday }

            it "generates the block as an adult" do
              block = XmlExtractor.call(xml, :global_merits, "CHILD_CLIENT")
              expect(block).to have_boolean_response false
              expect(block).not_to be_user_defined
            end
          end
        end

        describe "EMERGENCY_DPS_APP_AMD" do
          context "when delegated functions are used" do
            before do
              legal_aid_application.proceedings.each do |proceeding|
                proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: Date.yesterday, used_delegated_functions_reported_on: Date.current)
              end
            end

            it "generates the block with true" do
              block = XmlExtractor.call(xml, :global_merits, "EMERGENCY_DPS_APP_AMD")
              expect(block).to have_boolean_response true
              expect(block).not_to be_user_defined
            end
          end

          context "when delegated functions are NOT used" do
            it "generates the block with true" do
              block = XmlExtractor.call(xml, :global_merits, "EMERGENCY_DPS_APP_AMD")
              expect(block).to have_boolean_response false
              expect(block).not_to be_user_defined
            end
          end
        end

        describe "FAM_CERT_PREDICTED_COSTS" do
          it "generates the block with the standard value" do
            block = XmlExtractor.call(xml, :global_merits, "FAM_CERT_PREDICTED_COSTS")
            expect(block).to have_currency_response default_cost
            expect(block).not_to be_user_defined
          end
        end

        describe "MERITS_CERT_PREDICTED_COSTS" do
          it "generates the block with the standard value" do
            block = XmlExtractor.call(xml, :global_merits, "MERITS_CERT_PREDICTED_COSTS")
            expect(block).to have_currency_response default_cost
            expect(block).not_to be_user_defined
          end
        end

        describe "attributes with specific hard coded values" do
          it "IS_PASSPORTED should be hard coded to NO" do
            block = XmlExtractor.call(xml, :global_means, "IS_PASSPORTED")
            expect(block).to have_text_response "NO"
          end
        end

        describe "PROC_PREDICTED_COST_FAMILY" do
          it "generates the block with the standard value" do
            block = XmlExtractor.call(xml, :global_merits, "PROC_PREDICTED_COST_FAMILY")
            expect(block).to have_currency_response default_cost
            expect(block).not_to be_user_defined
          end
        end

        describe "PROFIT_COST_FAMILY" do
          it "generates a block with the value from the default proceeding" do
            block = XmlExtractor.call(xml, :proceeding_merits, "PROFIT_COST_FAMILY")
            expect(block).to have_currency_response default_cost
            expect(block).to be_user_defined
          end
        end

        describe "GB_INPUT_C_13WP3_4A" do
          it "is omitted" do
            block = XmlExtractor.call(xml, :global_means, "GB_INPUT_C_13WP3_4A")
            expect(block).not_to be_present
          end
        end

        describe "attributes omitted from payload" do
          it "does not display the attributes in the payload" do
            omitted_attributes.each do |entity_attribute_pair|
              entity, attribute = entity_attribute_pair
              block = XmlExtractor.call(xml, entity, attribute)
              expect(block).not_to be_present, "Expected block for attribute #{attribute} not to be generated, but was \n #{block}"
            end
          end
        end

        describe "GB_INFER_T_6WP1_66A" do
          it "is omitted" do
            block = XmlExtractor.call(xml, :global_merits, "GB_INFER_T_6WP1_66A")
            expect(block).not_to be_present
          end
        end

        describe "Proceeding Matter Type Descriptions" do
          let(:attrs) do
            %w[
              PROC_MATTER_TYPE_DESC
              PROC_MATTER_TYPE_MEANING
              PROC_MEANING
              PROCEEDING_DESCRIPTION
            ]
          end

          it "generates the block with the correct description" do
            attrs.each do |attr_name|
              block = XmlExtractor.call(xml, :proceeding_merits, attr_name)
              expect(block).to have_text_response legal_aid_application.lead_proceeding.description
              expect(block).not_to be_user_defined
            end
          end
        end

        describe "MEANS_ROUTING" do
          it "is set to MANB" do
            block = XmlExtractor.call(xml, :global_means, "MEANS_ROUTING")
            expect(block).to have_text_response "MANB"
          end
        end

        def will_attributes
          %w[
            WILL_INPUT_B_2WP2_10A
            WILL_INPUT_B_2WP2_21A
            WILL_INPUT_B_2WP2_24A
            WILL_INPUT_B_2WP2_26A
            WILL_INPUT_B_2WP2_27A
            WILL_INPUT_B_2WP2_28A
          ]
        end

        def conditional_valuable_possessions_attrs
          %w[
            VALPOSSESS_INPUT_B_12WP2_11A
            VALPOSSESS_INPUT_B_12WP2_12A
            VALPOSSESS_INPUT_B_12WP2_14A
            VALPOSSESS_INPUT_B_12WP2_15A
          ]
        end

        def conditional_trust_attributes
          %w[
            TRUST_INPUT_B_16WP2_19A
            TRUST_INPUT_B_16WP2_1A
            TRUST_INPUT_B_16WP2_2A
            TRUST_INPUT_B_16WP2_4A
            TRUST_INPUT_B_16WP2_5A
          ]
        end

        def conditional_timeshare_attrs
          %w[
            TIMESHARE_INPUT_N_6WP2_16A
            TIMESHARE_INPUT_N_6WP2_17A
            TIMESHARE_INPUT_N_6WP2_18A
            TIMESHARE_INPUT_N_6WP2_19A
          ]
        end

        def third_party_acct_attrs
          %w[
            THIRDPARTACC_INPUT_B_8WP2_11A
            THIRDPARTACC_INPUT_B_8WP2_12A
            THIRDPARTACC_INPUT_B_8WP2_13A
            THIRDPARTACC_INPUT_B_8WP2_15A
            THIRDPARTACC_INPUT_B_8WP2_17A
            THIRDPARTACC_INPUT_B_8WP2_18A
            THIRDPARTACC_INPUT_B_8WP2_19A
          ]
        end

        def money_due_attrs
          %w[
            MONEYDUE_INPUT_B_15WP2_18A
            MONEYDUE_INPUT_B_15WP2_1A
            MONEYDUE_INPUT_B_15WP2_21A
            MONEYDUE_INPUT_B_15WP2_2A
            MONEYDUE_INPUT_B_15WP2_4A
            MONEYDUE_INPUT_B_15WP2_5A
          ]
        end

        def life_assurance_attrs
          %w[
            LIFEASSUR_INPUT_B_13WP2_1A
            LIFEASSUR_INPUT_B_13WP2_2A
            LIFEASSUR_INPUT_B_13WP2_4A
            LIFEASSUR_INPUT_B_13WP2_5A
          ]
        end

        def conditional_land_attrs
          %w[
            LAND_INPUT_B_5WP2_11A
            LAND_INPUT_B_5WP2_14A
            LAND_INPUT_B_5WP2_20A
            LAND_INPUT_B_5WP2_22A
            LAND_INPUT_B_5WP2_23A
            LAND_INPUT_B_5WP2_24A
            LAND_INPUT_B_5WP2_25A
          ]
        end

        def global_means_main_dwelling_attrs
          %w[
            GB_INPUT_B_3WP2_16A
            GB_INPUT_B_3WP2_17A
            GB_INPUT_B_3WP2_18A
            GB_INPUT_B_3WP2_19A
            GB_INPUT_B_3WP2_20A
            GB_INPUT_B_3WP2_25A
          ]
        end

        def stocks_false_attrs
          %w[
            CLISTOCK_INPUT_B_9WP2_10A
            CLISTOCK_INPUT_B_9WP2_11A
            CLISTOCK_INPUT_B_9WP2_8A
            CLISTOCK_INPUT_B_9WP2_9A
          ]
        end

        def premium_bond_false_attrs
          %w[
            CLIPREMIUM_INPUT_B_9WP2_10A
            CLIPREMIUM_INPUT_B_9WP2_11A
            CLIPREMIUM_INPUT_B_9WP2_8A
            CLIPREMIUM_INPUT_B_9WP2_9A
          ]
        end

        def cli_capital_false_attrs
          %w[
            CLICAPITAL_INPUT_B_9WP2_10A
            CLICAPITAL_INPUT_B_9WP2_11A
            CLICAPITAL_INPUT_B_9WP2_8A
            CLICAPITAL_INPUT_B_9WP2_9A
          ]
        end

        def vehicle_false_attrs
          %w[
            CARANDVEH_INPUT_B_14WP2_1A
            CARANDVEH_INPUT_B_14WP2_2A
            CARANDVEH_INPUT_B_14WP2_4A
            CARANDVEH_INPUT_B_14WP2_5A
          ]
        end

        def bank_acct_false_attrs
          %w[
            BANKACC_INPUT_B_7WP2_19A
            BANKACC_INPUT_B_7WP2_21A
            BANKACC_INPUT_B_7WP2_22A
            BANKACC_INPUT_B_7WP2_23A
          ]
        end

        def additional_property_false_attrs
          [
            ["ADDPROPERTY_INFER_B_4WP2_52A", false],
            ["ADDPROPERTY_INPUT_B_4WP2_18A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_24A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_25A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_26A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_27A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_28A", true],
            ["ADDPROPERTY_INPUT_B_4WP2_32A", true],
          ]
        end

        def true_attributes
          [
            [:global_means, "GB_INPUT_B_40WP3_74A", true],
            [:global_means, "GB_INPUT_B_41WP3_23A", true],
            [:global_means, "GB_INPUT_B_41WP3_25A", true],
            [:global_means, "GB_INPUT_B_41WP3_29A", true],
            [:global_means, "GB_INPUT_B_41WP3_32A", true],
            [:global_means, "GB_INPUT_B_6WP3_233A", true],
            [:global_means, "GB_PROC_B_1WP4_99A", false],
            [:global_means, "LAR_SCOPE_FLAG", true],
            [:global_means, "MEANS_REQD", false],
            [:global_means, "SA_SCREEN10_1WP1_NONMEANS", false],
            [:global_merits, "MEDIATION_APPLICABLE", false],
            [:global_merits, "MENTAL_HEAL_QUESTION_APPLIES", false],
            [:global_merits, "MERITS_SUBMISSION_PAGE", true],
            [:global_merits, "NEW_APPLICATION", false],
            [:global_merits, "PROPORTIONALITY_QUESTION_APP", false],
            [:global_merits, "PROVIDER_HAS_DP", false],
            [:global_merits, "ROUTING_STD_FAMILY_MERITS", false],
            [:global_merits, "SA_INTRODUCTION", false],
            [:land, "LAND_INFER_B_5WP2_53A", false],
            [:land, "LAND_INFER_B_5WP2_54A", false],
            [:proceeding_merits, "LEAD_PROCEEDING_MERITS", false],
            [:proceeding_merits, "LEVEL_OF_SERV_FR", false],
            [:proceeding_merits, "PROC_OUTCOME_NO_OUTCOME", false],
            [:timeshare, "TIMESHARE_INFER_B_6WP2_20A", false],
            [:timeshare, "TIMESHARE_INFER_B_6WP2_21A", false],
            [:global_means, "GB_INPUT_B_40WP3_71A", true],
            [:global_means, "GB_INPUT_B_40WP3_73A", true],
            [:global_merits, "APPLICATION_CAN_BE_SUBMITTED", false],
            [:global_merits, "COPY_WARNING_LETTER", true],
            [:global_merits, "DP_WITH_JUDICIAL_REVIEW", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_BRINGING_PROCS", false],
          ]
        end

        def false_attributes
          [
            [:first_bank_acct_instance, "BANKACC_INPUT_B_7WP2_12A", true],
            [:first_bank_acct_instance, "BANKACC_INPUT_B_7WP2_14A", true],
            [:first_bank_acct_instance, "BANKACC_INPUT_B_7WP2_16A", true],
            [:global_means, "CLIENT_NASS", false],
            [:global_means, "CLIENT_PRISONER", false],
            [:global_means, "CLIENT_VULNERABLE", true],
            [:global_means, "GB_INFER_B_26WP3_214A", false],
            [:global_means, "GB_INPUT_B_12WP3_1A", true],
            [:global_means, "GB_INPUT_B_13WP3_15A", false],
            [:global_means, "GB_INPUT_B_13WP3_2A", false],
            [:global_means, "GB_INPUT_B_13WP3_37A", false],
            [:global_means, "GB_INPUT_B_13WP3_5A", true],
            [:global_means, "GB_INPUT_B_13WP3_7A", false],
            [:global_means, "GB_INPUT_B_1WP2_17A", true],
            [:global_means, "GB_INPUT_B_1WP2_19A", true],
            [:global_means, "GB_INPUT_B_1WP3_166A", true],
            [:global_means, "GB_INPUT_B_1WP3_167A", true],
            [:global_means, "GB_INPUT_B_1WP3_169A", true],
            [:global_means, "GB_INPUT_B_1WP3_170A", true],
            [:global_means, "GB_INPUT_B_1WP3_171A", true],
            [:global_means, "GB_INPUT_B_1WP3_172A", true],
            [:global_means, "GB_INPUT_B_1WP3_174A", true],
            [:global_means, "GB_INPUT_B_1WP3_175A", false],
            [:global_means, "GB_INPUT_B_1WP3_390A", true],
            [:global_means, "GB_INPUT_B_1WP3_400A", false],
            [:global_means, "GB_INPUT_B_1WP3_401A", false],
            [:global_means, "GB_INPUT_B_2WP4_2A", true],
            [:global_means, "GB_INPUT_B_9WP3_349A", true],
            [:global_means, "GB_INPUT_B_9WP3_350A", true],
            [:global_means, "GB_INPUT_B_9WP3_354A", true],
            [:global_means, "GB_INPUT_B_9WP3_355A", true],
            [:global_merits, "APP_CARE_SUPERVISION", false],
            [:global_merits, "APP_DIV_JUDSEP_DISSOLUTION_CP", false],
            [:global_merits, "APP_INCLUDES_IMMIGRATION_PROCS", false],
            [:global_merits, "APP_INCLUDES_INQUEST_PROCS", false],
            [:global_merits, "APP_INCLUDES_RELATED_PROCS", false],
            [:global_merits, "APP_INCLUDES_SCA_PROCS", false],
            [:global_merits, "APP_INC_CHILDREN_PROCS", false],
            [:global_merits, "APP_INC_CHILD_ABDUCTION", false],
            [:global_merits, "APP_INC_SECURE_ACCOM", false],
            [:global_merits, "APP_IS_SCA_RELATED", false],
            [:global_merits, "APP_POTENTIAL_NON_MERITS", false],
            [:global_merits, "APP_RELATES_EPO_EXTENDEPO_SAO", false],
            [:global_merits, "APP_SCA_NON_MERITS_TESTED", false],
            [:global_merits, "CASE_OWNER_COMPLEX_MERITS", false],
            [:global_merits, "CASE_OWNER_IMMIGRATION", false],
            [:global_merits, "CASE_OWNER_MENTAL_HEALTH", false],
            [:global_merits, "CASE_OWNER_SCA", false],
            [:global_merits, "CASE_OWNER_SCU", false],
            [:global_merits, "CASE_OWNER_VHCC", false],
            [:global_merits, "CHILD_MUST_BE_INCLUDED", false],
            [:global_merits, "CLIENT_CIVIL_PARTNER", false],
            [:global_merits, "CLIENT_CIVIL_PARTNER_DISSOLVE", false],
            [:global_merits, "CLIENT_COHABITING", false],
            [:global_merits, "CLIENT_DIVORCED", false],
            [:global_merits, "CLIENT_JUDICIALLY_SEPARATED", false],
            [:global_merits, "CLIENT_MARRIED", false],
            [:global_merits, "CLIENT_SINGLE", false],
            [:global_merits, "CLIENT_WIDOWED", false],
            [:global_merits, "CLINICAL_NEGLIGENCE", false],
            [:global_merits, "COMMUNITY_CARE", false],
            [:global_merits, "COPY_CA_UNSPENT_CONVICTION", false],
            [:global_merits, "COUNTY_COURT", false],
            [:global_merits, "COURT_OF_APPEAL", false],
            [:global_merits, "CRIME", false],
            [:global_merits, "CROWN_COURT", false],
            [:global_merits, "CURRENT_CERT_EMERGENCY", false],
            [:global_merits, "CURRENT_CERT_SUBSTANTIVE", false],
            [:global_merits, "DEC_AGAINST_INSTRUCTIONS", true],
            [:global_merits, "EDUCATION", false],
            [:global_merits, "EMERGENCY_DEC_SIGNED", false],
            [:global_merits, "EMPLOYMENT_APPEAL_TRIBUNAL", false],
            [:global_merits, "FIRST_TIER_TRIBUNAL_CARE_STAND", false],
            [:global_merits, "FIRST_TIER_TRIBUNAL_IMM_ASY", false],
            [:global_merits, "FIRST_TIER_TRIBUNAL_TAXATION", false],
            [:global_merits, "HIGH_COURT", false],
            [:global_merits, "HOUSING", false],
            [:global_merits, "IMMIGRATION", false],
            [:global_merits, "IMMIGRATION_CT_OF_APPEAL", false],
            [:global_merits, "IMMIGRATION_QUESTION_APP", false],
            [:global_merits, "ISSUE_URGENT_PROCEEDINGS", false],
            [:global_merits, "LEGAL_HELP_PROVIDED", true],
            [:global_merits, "LEGALLY_LINKED_SCU", false],
            [:global_merits, "LEGALLY_LINKED_SIU", false],
            [:global_merits, "LEGALLY_LINKED_VHCC", false],
            [:global_merits, "LIMITATION_PERIOD_TO_EXPIRE", false],
            [:global_merits, "MAGISTRATES_COURT", false],
            [:global_merits, "MATTER_IS_SWPI", false],
            [:global_merits, "MENTAL_HEALTH", false],
            [:global_merits, "MENTAL_HEALTH_REVIEW_TRIBUNAL", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_CORR", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_COUNSEL", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_CT_ORDER", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_EXPERT", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_PLEAD", false],
            [:global_merits, "NON_MAND_EVIDENCE_AMD_SOLS_RPT", false],
            [:global_merits, "NON_MAND_EVIDENCE_CORR_ADR", false],
            [:global_merits, "NON_MAND_EVIDENCE_CORR_SETTLE", false],
            [:global_merits, "NON_MAND_EVIDENCE_COUNSEL_OP", false],
            [:global_merits, "NON_MAND_EVIDENCE_CTORDER", false],
            [:global_merits, "NON_MAND_EVIDENCE_EXPERT_EXIST", false],
            [:global_merits, "NON_MAND_EVIDENCE_EXPERT_RPT", false],
            [:global_merits, "NON_MAND_EVIDENCE_ICA_LETTER", false],
            [:global_merits, "NON_MAND_EVIDENCE_LTTR_ACTION", false],
            [:global_merits, "NON_MAND_EVIDENCE_OMBUD_RPT", false],
            [:global_merits, "NON_MAND_EVIDENCE_PLEADINGS", false],
            [:global_merits, "NON_MAND_EVIDENCE_PRE_ACT_DISC", false],
            [:global_merits, "NON_MAND_EVIDENCE_SEP_STATE", false],
            [:global_merits, "NON_MAND_EVIDENCE_WARNING_LTTR", false],
            [:global_merits, "PREP_OF_STATEMENT_PAPERS", false],
            [:global_merits, "PROCS_INCLUDE_CHILD", false],
            [:global_merits, "PROSCRIBED_ORG_APPEAL_COMM", false],
            [:global_merits, "PUB_AUTH_QUESTION_APPLIES", false],
            [:global_merits, "PUBLIC_LAW_NON_FAMILY", false],
            [:global_merits, "REQUESTED_COST_LIMIT_OVER_25K", false],
            [:global_merits, "RISK_SCA_PR", false],
            [:global_merits, "ROUTING_COMPLEX_MERITS", false],
            [:global_merits, "ROUTING_IMMIGRATION", false],
            [:global_merits, "ROUTING_MENTAL_HEALTH", false],
            [:global_merits, "ROUTING_SCU", false],
            [:global_merits, "ROUTING_VHCC", false],
            [:global_merits, "SCA_APPEAL_INCLUDED", false],
            [:global_merits, "SCA_AUTO_GRANT", false],
            [:global_merits, "SMOD_APPLICABLE_TO_MATTER", false],
            [:global_merits, "SPECIAL_CHILDREN_ACT_APP", false],
            [:global_merits, "SPECIAL_IMM_APPEAL_COMMISSION", false],
            [:global_merits, "SUPREME_COURT", false],
            [:global_merits, "UPPER_TRIBUNAL_IMM_ASY", false],
            [:global_merits, "UPPER_TRIBUNAL_MENTAL_HEALTH", false],
            [:global_merits, "UPPER_TRIBUNAL_OTHER", false],
            [:global_merits, "URGENT_APPLICATION", false],
            [:global_merits, "URGENT_DIRECTIONS", false],
            [:other_capital, "OTHCAPITAL_INPUT_B_17WP2_1A", true],
            [:other_capital, "OTHCAPITAL_INPUT_B_17WP2_2A", true],
            [:other_capital, "OTHCAPITAL_INPUT_B_17WP2_4A", true],
            [:other_capital, "OTHCAPITAL_INPUT_B_17WP2_5A", true],
            [:other_savings, "OTHERSAVING_INPUT_B_10WP2_14A", true],
            [:other_savings, "OTHERSAVING_INPUT_B_10WP2_15A", true],
            [:other_savings, "OTHERSAVING_INPUT_B_10WP2_16A", true],
            [:other_savings, "OTHERSAVING_INPUT_B_10WP2_17A", true],
            [:proceeding_merits, "ACTION_DAMAGES_AGAINST_POLICE", false],
            [:proceeding_merits, "APPEAL_IN_SUPREME_COURT", false],
            [:proceeding_merits, "CLIENT_BRINGING_OR_DEFENDING", false],
            [:proceeding_merits, "CLIENT_DEFENDANT_3RD_PTY", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_APPELLANT", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_BRING_3RD_PTY", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_BRING_COUNTER", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_CHILD", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_DEF_COUNTER", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_DEFEND_PROCS", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_INTERPLEADER", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_INTERVENOR", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_JOINED_PARTY", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_OTHER", false],
            [:proceeding_merits, "CLIENT_INV_TYPE_PERSONAL_REP", false],
            [:proceeding_merits, "FAM_PROSP_BORDERLINE_UNCERT", false],
            [:proceeding_merits, "FAM_PROSP_GOOD", false],
            [:proceeding_merits, "FAM_PROSP_VERY_GOOD", false],
            [:proceeding_merits, "FAM_PROSP_VERY_POOR", false],
            [:proceeding_merits, "LEVEL_OF_SERV_FHH", false],
            [:proceeding_merits, "LEVEL_OF_SERV_IH", false],
            [:proceeding_merits, "LEVEL_OF_SERV_INQUEST", false],
            [:proceeding_merits, "NON_QUANTIFIABLE_REMEDY", false],
            [:proceeding_merits, "OVERWHELMING_IMPORTANCE", false],
            [:proceeding_merits, "PRIVATE_FUNDING_APPLICABLE", false],
            [:proceeding_merits, "PROC_CA_GATEWAY_APPLIES", false],
            [:proceeding_merits, "PROC_DV_GATEWAY_APPLIES", false],
            [:proceeding_merits, "PROC_IMMIGRATION_RELATED", false],
            [:proceeding_merits, "PROC_IS_SCA_APPEAL", false],
            [:proceeding_merits, "PROC_LAR_GATEWAY", false],
            [:proceeding_merits, "PROC_OUTCOME_RECORDED", false],
            [:proceeding_merits, "PROC_RELATED_PROCEEDING", false],
            [:proceeding_merits, "PROC_RELATED_SCA_OR_RELATED", false],
            [:proceeding_merits, "PROC_SCHED1_TRUE", false],
            [:proceeding_merits, "PROCEEDING_CASE_OWNER_SCU", false],
            [:proceeding_merits, "PROCEEDING_JUDICIAL_REVIEW", false],
            [:proceeding_merits, "SCA_APPEAL_FINAL_ORDER", false],
            [:proceeding_merits, "SIGNIFICANT_WIDER_PUB_INTEREST", false],
          ]
        end

        def omitted_attributes
          [
            [:global_merits, "DEC_AGAINST_INSTRUCT_SIGNED"],
            [:global_merits, "DEC_APP_NECESSARY"],
            [:global_merits, "DEC_CLIENT_TEXT_PARA16A"],
            [:global_merits, "DEC_CLIENT_TEXT_PARA17A"],
            [:global_merits, "DEC_CLIENT_TEXT_PARA18A"],
            [:global_merits, "DEC_NO_DIFFERENCES"],
            [:global_merits, "DEC_UNABLE_TO_ATTEND"],
            [:employment_entity, "OUT_EMP_INFER_C_15WP3_17A"],
            [:global_means, "OUT_GB_INFER_C_29WP3_18A"],
            [:global_means, "OUT_GB_PROC_C_34WP3_12A"],
            [:proceeding_merits, "FAM_PROSP_50_OR_BETTER"],
            [:proceeding_merits, "FAM_PROSP_BORDER_UNCERT_POOR"],
            [:proceeding_merits, "FAM_PROSP_MARGINAL"],
            [:proceeding_merits, "FAM_PROSP_POOR"],
            [:proceeding_merits, "FAM_PROSP_UNCERTAIN"],
          ]
        end
      end
    end
  end
end
