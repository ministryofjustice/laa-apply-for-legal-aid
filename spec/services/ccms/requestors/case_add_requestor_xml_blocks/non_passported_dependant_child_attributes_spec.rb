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

        let!(:adult_dependant) { create(:dependant, :over18, legal_aid_application:, number: 3, assets_value: 8_000.01) }
        let(:ccms_reference) { "300000054005" }
        let(:submission) { create(:submission, :case_ref_obtained, legal_aid_application:, case_ccms_reference: ccms_reference) }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }
        let(:dependants) { legal_aid_application.dependants.all }

        before do
          create(:chances_of_success, :with_optional_text, proceeding:)
          create(:cfe_v3_result, submission: cfe_submission)
        end

        describe "non-passported" do
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
                   office:)
          end
          let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }

          context "with dependant children" do
            let!(:younger_child) { create(:dependant, :under15, legal_aid_application:, number: 1, has_income: false, assets_value: 1_000) }
            let!(:older_child) { create(:dependant, :child16_to18, legal_aid_application:, number: 2, has_income: true, assets_value: 0) }

            context "and variable attributes" do
              describe "attribute CLI_RES_PER_INPUT_T_12WP3_1A - Person residing: name" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_T_12WP3_1A") }
                let(:sorted_blocks) { blocks.sort { |a, b| a.css("ResponseValue").text <=> b.css("ResponseValue").text } }

                it "generates one block per dependant regardless of whether they are adults or children" do
                  expect(blocks.size).to eq dependants.size
                end

                it "includes block with name" do
                  expected_names = dependants.map(&:name).sort
                  sorted_blocks.each_with_index do |block, i|
                    expect(block).to have_text_response expected_names[i]
                  end
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_30A - Person residing: Employed?" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_30A") }

                it "only generates a block for the adult_dependants" do
                  expect(blocks.size).to eq dependants.adult_relative.size
                end

                it "generates false for every block" do
                  expect(blocks).to all(have_boolean_response(false))
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_31A - Dependant: receive their own income?" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_31A") }

                it "generates a block only for adult dependants" do
                  expect(blocks.size).to eq dependants.adult_relative.size
                end

                it "generates false for every block" do
                  expect(blocks).to all(have_boolean_response(false))
                end
              end

              describe "attribute CLI_RES_PER_INPUT_T_12WP3_17A - Person residing: relationship to client" do
                before do
                  legal_aid_application.dependants.map(&:destroy!)
                  create(:dependant, legal_aid_application:, date_of_birth: dob, relationship:)
                  legal_aid_application.reload
                end

                context "when adult_relative" do
                  let(:relationship) { "adult_relative" }
                  let(:dob) { 22.years.ago }
                  let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_T_12WP3_17A") }

                  it "generates just one block" do
                    expect(blocks.size).to eq 1
                  end

                  it "generated Dependent adult as relationship" do
                    expect(blocks.first).to have_text_response "Dependent adult"
                  end
                end

                context "when child 15 or less" do
                  let(:relationship) { "child_relative" }
                  let(:dob) { 14.years.ago }
                  let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_T_12WP3_17A") }

                  it "generated under 15 child as relationship" do
                    expect(blocks.first).to have_text_response "Child aged 15 and under"
                  end
                end

                context "when child 16 or more" do
                  let(:relationship) { "child_relative" }
                  let(:dob) { 17.years.ago }
                  let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_T_12WP3_17A") }

                  it "generated over 16 child as relationship" do
                    expect(blocks.first).to have_text_response "Child aged 16 and over"
                  end
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_35A - Person residing: entitled to claim benefits?" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_35A") }

                it "only produces a block for adult relatives" do
                  expect(dependants.size > dependants.adult_relative.size).to be true
                  expect(blocks.size).to eq dependants.adult_relative.size
                end

                it "hard-codes the value to false" do
                  expect(blocks).to all(have_boolean_response(false))
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_19A - Person residing: Capital over £8000?" do
                before { dependants.each { |dep| dep.update!(assets_value: value) } }

                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_19A") }

                context "when all dependants have over £8,000 of assets" do
                  let(:value) { 8_000.01 }

                  it "codes all blocks to true" do
                    expect(blocks).to all(have_boolean_response(true))
                  end
                end

                context "when all dependants have less than £8,000 in assets" do
                  let(:value) { 7_999.99 }

                  it "codes all blocks to false" do
                    expect(blocks).to all(have_boolean_response(false))
                  end
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_21A - Dependant: Relationship is child aged 15 and under" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_21A") }

                it "is true for the younger child" do
                  block = blocks.first
                  expect(block).to have_boolean_response true
                end

                it "is false for the older child" do
                  block = blocks.last
                  expect(block).to have_boolean_response false
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_23A - Person Residing: The child receives their own income?" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_23A") }

                it "is false for the younger child without income" do
                  block = blocks.first
                  expect(block).to have_boolean_response false
                end

                it "is true for the older child with income" do
                  block = blocks.last
                  expect(block).to have_boolean_response true
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_24A - Dependant: Relationship is child aged 16 and over" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_24A") }

                it "is false for the younger child" do
                  block = blocks.first
                  expect(block).to have_boolean_response false
                end

                it "is true for the older child" do
                  block = blocks.last
                  expect(block).to have_boolean_response true
                end
              end

              describe "attribute CLI_RES_PER_INPUT_B_12WP3_28A - Dependant: Relationship is adult" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_B_12WP3_28A") }

                before { dependants.each { |dep| dep.update!(relationship:) } }

                context "when all dependants are children" do
                  let(:relationship) { "child_relative" }

                  it "returns false for all blocks" do
                    expect(blocks).to all(have_boolean_response(false))
                  end
                end

                context "when all dependants are adults" do
                  let(:relationship) { "adult_relative" }

                  it "returns true for all blocks" do
                    expect(blocks).to all(have_boolean_response(true))
                  end
                end
              end

              describe "attribute CLI_RES_PER_INPUT_D_12WP3_3A - Person residing: DOB" do
                let(:blocks) { XmlExtractor.call(xml, :client_residing_person, "CLI_RES_PER_INPUT_D_12WP3_3A") }

                before do
                  adult_dependant.update!(date_of_birth: Date.new(2000, 5, 6))
                  older_child.update!(date_of_birth: Date.new(2018, 1, 8))
                  younger_child.update!(date_of_birth: Date.new(2021, 3, 2))
                end

                it "generates the dates correctly" do
                  # sort the blocks to ensure order is 02-03-2021, 06-05-2000, 08-01-2018
                  sorted_blocks = blocks.sort { |a, b| a.css("ResponseValue").text <=> b.css("ResponseValue").text }
                  expect(sorted_blocks[0]).to have_date_response "02-03-2021"
                  expect(sorted_blocks[1]).to have_date_response "06-05-2000"
                  expect(sorted_blocks[2]).to have_date_response "08-01-2018"
                end
              end
            end

            describe "hard coded attributes" do
              let(:hard_coded_attrs) do
                [
                  # key for XmlExtractor xpath, attribute name, response type, user_defined?, expected_value
                  ["client_residing_person", "CLI_RES_PER_INPUT_B_12WP3_20A", "boolean", false, false],
                  ["client_residing_person", "CLI_RES_PER_INPUT_B_12WP3_32A", "boolean", false, false],
                ]
              end

              it "generates a CLIENT RESIDING PERSON ENTITY" do
                entity = XmlExtractor.call(xml, :client_residing_person_entity)
                expect(entity).to be_present
              end

              it "generates the an attribute block for each dependant" do
                hard_coded_attrs.each do |attr|
                  entity, attr_name, _type, _user_defined, _value = attr
                  blocks = XmlExtractor.call(xml, entity.to_sym, attr_name)
                  expect(blocks.size).to eq dependants.size
                end
              end

              it "generates the expected block for each of the hard coded attrs" do
                hard_coded_attrs.each do |attr|
                  entity, attr_name, type, user_defined, value = attr
                  blocks = XmlExtractor.call(xml, entity.to_sym, attr_name)

                  blocks.each do |block|
                    case type
                    when "number"
                      expect(block).to have_number_response value.to_i
                    when "text"
                      expect(block).to have_text_response value
                    when "currency"
                      expect(block).to have_currency_response value
                    when "date"
                      expect(block).to have_date_response value
                    when "boolean"
                      expect(block).to have_boolean_response value
                    else raise "Unexpected type"
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

          context "without dependants" do
            before { dependants.map(&:destroy!) }

            it "does not generate a client residing person entity" do
              entity = XmlExtractor.call(xml, :client_residing_person_entity)
              expect(entity).to be_empty
            end
          end
        end
      end
    end
  end
end
