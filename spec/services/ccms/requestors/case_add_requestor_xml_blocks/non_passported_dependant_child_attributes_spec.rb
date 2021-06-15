require 'rails_helper'

module CCMS
  module Requestors # rubocop:disable Metrics/ModuleLength
    RSpec.describe NonPassportedCaseAddRequestor do
      context 'XML request' do
        let(:expected_tx_id) { '201904011604570390059770666' }
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

        let!(:adult_dependant) { create :dependant, :over18, legal_aid_application: legal_aid_application, number: 3 }
        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }

        context 'non-passported' do
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

          context 'with dependant children' do
            let!(:younger_child) { create :dependant, :under15, legal_aid_application: legal_aid_application, number: 1, has_income: false }
            let!(:older_child) { create :dependant, :child16_to18, legal_aid_application: legal_aid_application, number: 2, has_income: true }

            context 'variable attributes' do
              context 'attribute CLI_RES_PER_INPUT_B_12WP3_21A - Dependant: Relationship is child aged 15 and under' do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, 'CLI_RES_PER_INPUT_B_12WP3_21A') }

                it 'is true for the younger child' do
                  block = blocks.first
                  expect(block).to have_boolean_response true
                end

                it 'is false for the older child' do
                  block = blocks.last
                  expect(block).to have_boolean_response false
                end
              end

              context 'attribute CLI_RES_PER_INPUT_B_12WP3_23A - Person Residing: The child receives their own income?' do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, 'CLI_RES_PER_INPUT_B_12WP3_23A') }

                it 'is false for the younger child without income' do
                  block = blocks.first
                  expect(block).to have_boolean_response false
                end

                it 'is true for the older child with income' do
                  block = blocks.last
                  expect(block).to have_boolean_response true
                end
              end

              context 'attribute CLI_RES_PER_INPUT_B_12WP3_24A - Dependant: Relationship is child aged 16 and over' do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, 'CLI_RES_PER_INPUT_B_12WP3_24A') }

                it 'is false for the younger child' do
                  block = blocks.first
                  expect(block).to have_boolean_response false
                end

                it 'is true for the older child' do
                  block = blocks.last
                  expect(block).to have_boolean_response true
                end
              end
            end

            context 'hard coded attributes' do
              let(:hard_coded_attrs) do
                [
                  # key for XmlExtractor xpath, attribute name, response type, user_defined?, expected_value
                  ['client_residing_person', 'CLI_RES_PER_INPUT_B_12WP3_20A', 'boolean', false, false]
                ]
              end

              it 'generates a CLIENT RESIDING PERSON ENTITY' do
                entity = XmlExtractor.call(xml, :client_residing_person_entity)
                expect(entity).to be_present
              end

              it 'generates the an attribute block for each dependant child' do
                hard_coded_attrs.each do |attr|
                  entity, attr_name, _type, _user_defined, _value = attr
                  blocks = XmlExtractor.call(xml, entity.to_sym, attr_name)
                  expect(blocks.size).to eq 2
                end
              end

              it 'generates the expected block for each of the hard coded attrs' do
                hard_coded_attrs.each do |attr|
                  entity, attr_name, type, user_defined, value = attr
                  blocks = XmlExtractor.call(xml, entity.to_sym, attr_name)

                  blocks.each do |block|
                    case type
                    when 'number'
                      expect(block).to have_number_response value.to_i
                    when 'text'
                      expect(block).to have_text_response value
                    when 'currency'
                      expect(block).to have_currency_response value
                    when 'date'
                      expect(block).to have_date_response value
                    when 'boolean'
                      expect(block).to have_boolean_response value
                    else raise 'Unexpected type'
                    end

                    case user_defined
                    when true
                      expect(block).to be_user_defined
                    else
                      expect(block).not_to be_user_defined
                    end
                  end
                end
              end
            end
          end

          context 'without dependant children' do
            it 'does not generate a client residing person entity' do
              entity = XmlExtractor.call(xml, :client_residing_person_entity)
              expect(entity).to be_empty
            end
          end
        end

        context 'passported' do
          let(:legal_aid_application) do
            create :legal_aid_application,
                   :with_everything,
                   :with_applicant_and_address,
                   :with_positive_benefit_check_result,
                   :with_proceeding_types,
                   :with_chances_of_success,
                   populate_vehicle: true,
                   with_bank_accounts: 2,
                   provider: provider,
                   office: office
          end

          it 'does not generate a client residing person entity' do
            entity = XmlExtractor.call(xml, :client_residing_person_entity)
            expect(entity).to be_empty
          end
        end
      end
    end
  end
end
