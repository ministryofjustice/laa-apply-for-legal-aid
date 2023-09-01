require "rails_helper"

module CCMS
  RSpec.describe AttributeConfiguration, :ccms do
    before do
      allow_any_instance_of(described_class).to receive(:configuration_files).and_return(mock_configuration)
    end

    context "with standard application_type" do
      subject(:config) { described_class.new(application_type: :standard).config }

      it "returns the existing un-merged hash" do
        expect(config).to eq YAML.load_file(mock_configuration[:standard]).deep_symbolize_keys
      end
    end

    context "with non_passported application_type" do
      subject(:config) { described_class.new(application_type: :non_passported).config }

      it "has all sections from standard and merged configs" do
        expect(config.keys).to match_array(%i[bank_acct employment applicant new_section])
      end

      context "when new attribute block in existing section" do
        it "has the configuration from the merged hash" do
          new_attr_block = config[:bank_acct][:NEW_ATTR_IN_EXISTING_SECTION]
          expect(new_attr_block.keys).to eq %i[value br100_meaning response_type user_defined]
          expect(new_attr_block[:value]).to eq "#new attr in existing section"
          expect(new_attr_block[:br100_meaning]).to eq "Bank accounts: new attr"
          expect(new_attr_block[:response_type]).to eq "text"
          expect(new_attr_block[:user_defined]).to be true
        end
      end

      context "when one key's value is replaced in an existing attribute block" do
        it "replaces the one key's value that has been specified in the merged file and contains all the other originals" do
          modified_attr_block = config[:bank_acct][:BALANCE]
          expect(modified_attr_block.keys).to eq %i[value br100_meaning response_type user_defined]
          expect(modified_attr_block[:value]).to eq "#new_bank_balance_method"
          expect(modified_attr_block[:br100_meaning]).to eq "Bank accounts: Current Balance"
          expect(modified_attr_block[:response_type]).to eq "currency"
          expect(modified_attr_block[:user_defined]).to be true
        end
      end

      context "when an additional key-value pair is added to existing attribute block in merged config file" do
        it "adds the new value and leaves all the other unchanged" do
          modified_attr_block = config[:bank_acct][:ACCOUNT_NUMBER]
          expect(modified_attr_block.keys).to eq %i[value br100_meaning response_type user_defined generate_block?]
          expect(modified_attr_block[:generate_block?]).to be false
          expect(modified_attr_block[:value]).to eq "#bank_account_account_number"
          expect(modified_attr_block[:br100_meaning]).to eq "Bank accounts: Account number"
          expect(modified_attr_block[:response_type]).to eq "text"
          expect(modified_attr_block[:user_defined]).to be true
        end
      end

      context "when new section exists in merged config file" do
        it "adds the new section and any nested attributes" do
          new_section = config[:new_section]
          expect(new_section).to eq(
            NEW_SECTION_ATTR_1: {
              value: "#new_section_attr_1",
              br100_meaning: "Attr 1",
              response_type: "text",
              user_defined: true,
            },
            NEW_SECTION_ATTR: {
              value: "#new_seciton_attr_2",
              br100_meaning: "Attr 2",
              response_type: "text",
              user_defined: false,
            },
          )
        end
      end

      context "when section in standard file but not in merged config file" do
        it "keeps the section unaltered" do
          existing_section = config[:applicant]
          expect(existing_section).to eq(
            NAME: {
              value: "#applicant name",
              br100_meaning: "Applicant: name",
              response_type: "text",
              user_defined: false,
            },
            AGE: {
              value: "#applicant age",
              br100_meaning: "Applicant: age",
              response_type: "number",
              user_defined: true,
            },
          )
        end
      end
    end

    context "with non_means_tested application_type" do
      subject(:config) { described_class.new(application_type: :non_means_tested).config }

      it "has all sections from standard and merged configs" do
        expect(config.keys).to match_array(%i[bank_acct employment applicant])
      end

      it "has the new key-value pairs from the merged config file" do
        expect(config[:bank_acct][:BALANCE][:generate_block?]).to be false
        expect(config[:bank_acct][:ACCOUNT_NUMBER][:generate_block?]).to be false
        expect(config[:bank_acct][:HOLDERS][:generate_block?]).to be false
        expect(config[:bank_acct][:BANK_NAME][:generate_block?]).to be false
        expect(config[:employment][:EMPLOYER_NAME][:generate_block?]).to be false
        expect(config[:employment][:EMPLOYER_TYPE][:generate_block?]).to be false
      end
    end

    context "when an invalid application type is provided" do
      subject(:config) { described_class.new(application_type: :unknown_type).config }

      it "raises" do
        expect { config }.to raise_error ArgumentError, "Invalid application type"
      end
    end

    def mock_configuration
      {
        standard: Rails.root.join("spec/fixtures/files/ccms_keys/standard_keys.yml"),
        non_means_tested: Rails.root.join("spec/fixtures/files/ccms_keys/merged_in_non_means_tested_keys.yml"),
        non_passported: Rails.root.join("spec/fixtures/files/ccms_keys/merged_in_non_passported_keys.yml"),
      }
    end
  end
end
