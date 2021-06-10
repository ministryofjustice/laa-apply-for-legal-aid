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
                 :with_chances_of_success,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider: provider,
                 office: office
        end

        let(:application_proceeding_type) do
          create :application_proceeding_type, :with_substantive_scope_limitation, legal_aid_application: legal_aid_application, proceeding_type: proceeding_type
        end
        let(:opponent) { legal_aid_application.opponent }
        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:success_prospect) { :likely }

        before do
          legal_aid_application.reload
        end

        # enable this context if you need to create a file of the payload for manual inspection
        # context 'saving to a temporary file', skip: 'Not needed for testing - but useful if you want to save the payload to a file' do
        # context 'save to a temporary file' do
        #   it 'creates a file' do
        #     filename = Rails.root.join('tmp/generated_non_passported_ccms_payload.xml')
        #     File.open(filename, 'w') { |f| f.puts xml }
        #     expect(File.exist?(filename)).to be true
        #   end
        # end

        context 'entity CLINATIONAL' do
          before { savings_amount.update! national_savings: 1234 }
          context 'applicant has national savings' do
            it 'generates an entity block' do
              expect(xml).to have_means_entity 'CLINATIONAL'
            end

            it 'generates all the false attributes correctly' do
              %w[ CLINATIONAL_INPUT_B_9WP2_10A
                  CLINATIONAL_INPUT_B_9WP2_11A
                  CLINATIONAL_INPUT_B_9WP2_8A
                  CLINATIONAL_INPUT_B_9WP2_9A ].each do |attr_name|
                block = XmlExtractor.call(xml, :national_savings, attr_name)
                expect(block).to have_boolean_response false
              end
            end

            it 'generates a dot for the attribute' do
              block = XmlExtractor.call(xml, :national_savings, 'CLINATIONAL_INPUT_T_9WP2_12A')
              expect(block).to have_text_response '.'
            end
          end

          context 'applicant has no national savings' do
            before { savings_amount.update! national_savings: nil }
            it 'does not generate the entity block' do
              expect(xml).not_to have_means_entity 'CLINATIONAL'
            end
          end
        end

        context 'entity VALUABLE_POSSESSION' do
          context 'applicant has valuable_posssessions' do
            before { other_assets_decl.update! valuable_items_value: 878_787 }
            it 'generates an entity block' do
              expect(xml).to have_means_entity 'VALUABLE_POSSESSION'
            end
          end

          context 'applicant has no valuable_posssessions' do
            before { other_assets_decl.update! valuable_items_value: nil }
            it 'generates an entity block' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              entity_block = doc.xpath('//MeansAssesments//AssesmentDetails//Entity[EntityName = "VALUABLE_POSSESSION"]')
              expect(entity_block).to be_empty
            end
          end
        end

        context 'entity CAPITAL_SHARE' do
          before { savings_amount.update! plc_shares: 1234 }
          context 'applicant has capital shares' do
            it 'generates an entity block' do
              expect(xml).to have_means_entity 'CAPITAL_SHARE'
            end

            it 'generates a 1 for the attribute' do
              block = XmlExtractor.call(xml, :plc_shares, 'CAPSHARE_INPUT_N_11WP2_8A')
              expect(block).to have_number_response(1)
            end

            it 'generates all the false attributes correctly' do
              %w[ CAPSHARE_INPUT_B_11WP2_19A
                  CAPSHARE_INPUT_B_11WP2_20A
                  CAPSHARE_INPUT_B_11WP2_22A
                  CAPSHARE_INPUT_B_11WP2_23A ].each do |attr_name|
                block = XmlExtractor.call(xml, :plc_shares, attr_name)
                expect(block).to have_boolean_response false
              end
            end

            it 'generates a dot for relevant attributes' do
              %w[ CAPSHARE_INPUT_T_11WP2_6A
                  CAPSHARE_INPUT_T_11WP2_7A ].each do |attr_name|
                block = XmlExtractor.call(xml, :plc_shares, attr_name)
                expect(block).to have_text_response('.')
              end
            end
          end

          context 'applicant has no capital shares' do
            before { savings_amount.update! plc_shares: nil }
            it 'does not generate the entity block' do
              expect(xml).not_to have_means_entity 'CAPITAL_SHARE'
            end
          end
        end

        context 'bank accounts entity' do
          context 'bank accounts present' do
            it 'creates the entity' do
              expect(xml).to have_means_entity 'BANKACC'
            end

            it 'adds the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "BANKACC"]/Instances/InstanceLabel').text
              expect(instance_label).to include 'the bank account1'
            end
          end

          context 'no bank accounts present' do
            let(:legal_aid_application) do
              create :legal_aid_application,
                     :with_everything,
                     :with_applicant_and_address,
                     :with_positive_benefit_check_result,
                     :with_proceeding_types,
                     :with_chances_of_success,
                     vehicle: nil,
                     office: office
            end

            it 'does not generate the bank accounts entity' do
              block = XmlExtractor.call(xml, :bank_accounts_entity)
              expect(block).not_to be_present, "Expected block for bank accounts entity not to be generated, but was \n #{block}"
            end
          end
        end

        context 'entity CLIENT_FINANCIAL_SUPPORT' do
          context 'applicant has no financial support' do
            it 'does not generate the entity' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              entity_block = doc.xpath('//MeansAssesments//AssesmentDetails//Entity[EntityName = "CLIENT_FINANCIAL_SUPPORT"]')
              expect(entity_block).to be_empty
            end
          end

          context 'applicant has financial support' do
            let(:applicant) { legal_aid_application.applicant }
            let(:bank_provider) { create :bank_provider, applicant: applicant }
            let(:bank_account) { create :bank_account, bank_provider: bank_provider }
            let!(:bank_transactions) { create_list :bank_transaction, 2, :friends_or_family, bank_account: bank_account }

            it 'generate the entity' do
              expect(xml).to have_means_entity 'CLIENT_FINANCIAL_SUPPORT'
            end

            it 'generates an attribute block for CLI_FIN_SUPP_INPUT_B_8WP3_8A' do
              block = XmlExtractor.call(xml, :financial_support, 'CLI_FIN_SUPP_INPUT_B_8WP3_8A')
              expect(block).to have_boolean_response true
            end
          end
        end

        context 'entity CHANGE_IN_CIRCUMSTANCE' do
          it 'generate the entity' do
            doc = Nokogiri::XML(xml).remove_namespaces!
            entity_block = doc.xpath('//MeansAssesments//AssesmentDetails//Entity[EntityName = "CHANGE_IN_CIRCUMSTANCE"]')
            expect(entity_block).not_to be_empty
          end

          it 'generates the CHANGE_CIRC_INPUT_T_33WP3_6A attribute block' do
            block = XmlExtractor.call(xml, :change_in_circumstance, 'CHANGE_CIRC_INPUT_T_33WP3_6A')
            expect(block).to have_text_response '.'
          end

          it 'includes the correct ccms instance label ' do
            doc = Nokogiri::XML(xml).remove_namespaces!
            instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "CHANGE_IN_CIRCUMSTANCE"]/Instances/InstanceLabel').text
            expect(instance_label).to eq 'the change in circumstance1'
          end
        end

        context 'entity CARS_AND_MOTOR_VEHICLES' do
          context 'the applicant has a car' do
            it 'generates the entity' do
              expect(xml).to have_means_entity 'CARS_AND_MOTOR_VEHICLES'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "CARS_AND_MOTOR_VEHICLES"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'the cars & motor vehicle1'
            end
          end

          context 'the applicant does not have a car' do
            before do
              legal_aid_application.vehicle.destroy!
              legal_aid_application.reload
            end

            it 'does not generates the entity' do
              expect(xml).not_to have_means_entity 'CARS_AND_MOTOR_VEHICLES'
            end
          end
        end

        context 'entity THIRDPARTACC' do
          context 'the applicant has access to third party accounts' do
            before { legal_aid_application.savings_amount.update! other_person_account: 3_663_377 }
            it 'generates the entity' do
              expect(xml).to have_means_entity 'THIRDPARTACC'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "THIRDPARTACC"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'the third party bank account1'
            end
          end

          context 'applicant does not have access to thrid party accounts' do
            before { legal_aid_application.savings_amount.update! other_person_account: nil }
            it 'does not generates the entity' do
              expect(xml).not_to have_means_entity 'THIRDPARTACC'
            end
          end
        end

        context 'entity CLIENT_BENEFIT_PENDING' do
          it 'does not generate the entity' do
            expect(xml).not_to have_means_entity 'CLIENT_BENEFIT_PENDING'
          end
        end

        context 'entity CLIPREMIUM' do
          context 'client has premium bonds' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'CLIPREMIUM'
            end
          end

          context 'client has no premium bonds' do
            before { legal_aid_application.savings_amount.update! national_savings: nil }
            it 'does not generate the entity' do
              expect(xml).not_to have_means_entity 'CLIPREMIUM'
            end
          end
        end

        context 'entity MONEY_DUE' do
          context 'applicant has money owing to them' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'MONEY_DUE'
            end
          end

          context 'applicant does not have money owing to them' do
            before { legal_aid_application.other_assets_declaration.update! money_owed_value: nil }
            it 'does not generate the entity block' do
              expect(xml).not_to have_means_entity 'MONEY_DUE'
            end
          end
        end

        context 'entity PROCEEDING' do
          it 'generates the entity block' do
            expect(xml).to have_means_entity 'PROCEEDING'
          end
        end

        context 'entity CLICAPITAL' do
          context 'applicant has capital bonds' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'CLICAPITAL'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "CLICAPITAL"]/Instances/InstanceLabel').text
              expect(instance_label).to eq "the client's capital bond1"
            end
          end

          context 'applicant does not have capital bonds' do
            before { legal_aid_application.savings_amount.update! peps_unit_trusts_capital_bonds_gov_stocks: nil }
            it 'does not generates the entity block' do
              expect(xml).not_to have_means_entity 'CLICAPITAL'
            end
          end
        end

        context 'entity OPPONENT_OTHER_PARTIES' do
          it 'generates attribute block' do
            expect(xml).to have_means_entity 'OPPONENT_OTHER_PARTIES'
          end
        end

        context 'entity LAND' do
          context 'applicant has land' do
            it 'generates entity block' do
              expect(xml).to have_means_entity 'LAND'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "LAND"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'the land1'
            end
          end

          context 'applicant has no land' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'LAND'
            end
          end
        end

        context 'entity TIMESHARE' do
          context 'applicant has a timeshare' do
            it 'generates entity block' do
              expect(xml).to have_means_entity 'TIMESHARE'
            end
          end

          context 'applicant has no timeshare' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'TIMESHARE'
            end
          end
        end

        context 'entity global' do
          it 'generates the entity block' do
            expect(xml).to have_means_entity 'global'
          end
        end

        context 'entity OTHERSAVING' do
          it 'generates the entity block' do
            expect(xml).to have_means_entity 'OTHERSAVING'
          end
        end

        context 'entity CAR_USED' do
          context 'applicant has vehicle' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'CAR_USED'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "CAR_USED"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'the car used1'
            end
          end

          context 'applicant has no vehicle' do
            before do
              legal_aid_application.vehicle.destroy!
              legal_aid_application.reload
            end
            it 'does not generates the entity block' do
              expect(xml).not_to have_means_entity 'CAR_USED'
            end
          end
        end

        context 'entity ADDPROPERTY' do
          context 'applicant has additional property' do
            before { legal_aid_application.other_assets_declaration.update! second_home_value: 244_000 }
            it 'generates entity block' do
              expect(xml).to have_means_entity 'ADDPROPERTY'
            end

            it 'generates instance label containing the case referernce' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              case_ref = doc.xpath('//CaseReferenceNumber').text
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "ADDPROPERTY"]/Instances/InstanceLabel').text
              expect(instance_label).to eq "#{case_ref}:ADDPROPERTY_001"
            end
          end

          context 'applicant does not hae second property' do
            before { legal_aid_application.other_assets_declaration.update! second_home_value: nil }
            it 'does not generates entity block' do
              expect(xml).not_to have_means_entity 'ADDPROPERTY'
            end
          end
        end

        context 'entity CLISTOCK' do
          context 'applicant has shares' do
            it 'generates entity block' do
              expect(xml).to have_means_entity 'CLISTOCK'
            end
          end

          context 'applicant has no shares' do
            before { legal_aid_application.savings_amount.update! plc_shares: nil }
            it 'does not generate entity block' do
              expect(xml).not_to have_means_entity 'CLISTOCK'
            end
          end
        end

        context 'entity LIFE_ASSURANCE' do
          context 'applicant has life assurance' do
            it 'generates entity block' do
              expect(xml).to have_means_entity 'LIFE_ASSURANCE'
            end

            it 'adds the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "LIFE_ASSURANCE"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'life assurance & endowment policy1'
            end
          end

          context 'applicant has no life assurance' do
            before { legal_aid_application.savings_amount.update! life_assurance_endowment_policy: nil }
            it 'does not generate entity block' do
              expect(xml).not_to have_means_entity 'LIFE_ASSURANCE'
            end
          end
        end

        context 'entity MAINTHIRD' do
          context 'applicant does not own a property' do
            before { legal_aid_application.update! own_home: 'no', property_value: nil, percentage_home: nil }
            it 'does not generate entity block' do
              expect(xml).not_to have_means_entity 'MAINTHIRD'
            end
          end

          context 'applicant owns 100% of a property' do
            before { legal_aid_application.update! property_value: 256_000, percentage_home: 100.0 }
            it 'does not generate entity block' do
              expect(xml).not_to have_means_entity 'MAINTHIRD'
            end
          end

          context 'applicant owns share of a property' do
            before { legal_aid_application.update! property_value: 256_000, percentage_home: 60.0 }
            it 'generates entity block' do
              expect(xml).to have_means_entity 'MAINTHIRD'
            end
          end
        end

        context 'entity OTHER_CAPITAL' do
          it 'generates the entitiy block' do
            expect(xml).to have_means_entity 'OTHER_CAPITAL'
          end
        end

        context 'entity WILL' do
          context 'applicant has inherited assets' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'WILL'
            end
          end

          context 'applicant has no inherited assets' do
            before { legal_aid_application.other_assets_declaration.update! inherited_assets_value: 0.0 }
            it 'does not generate the entity block' do
              expect(xml).not_to have_means_entity 'WILL'
            end
          end
        end

        context 'entity TRUST' do
          context 'applicant is the beneficiary of a trust' do
            it 'generates the entity block' do
              expect(xml).to have_means_entity 'TRUST'
            end

            it 'includes the correct ccms instance label ' do
              doc = Nokogiri::XML(xml).remove_namespaces!
              instance_label = doc.xpath(' //MeansAssesments//AssesmentDetails//Entity[EntityName = "TRUST"]/Instances/InstanceLabel').text
              expect(instance_label).to eq 'the trust1'
            end
          end

          context 'applicant is not the beneficiary of a trust' do
            before { legal_aid_application.other_assets_declaration.update! trust_value: nil }
            it 'does not generate the entity block' do
              expect(xml).not_to have_means_entity 'TRUST'
            end
          end
        end
      end
    end
  end
end
