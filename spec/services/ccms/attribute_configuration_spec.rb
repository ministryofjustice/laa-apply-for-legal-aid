require 'rails_helper'

module CCMS
  RSpec.describe AttributeConfiguration do
    before do
      allow_any_instance_of(described_class).to receive(:configuration_files).and_return(mock_configuration)
    end

    context 'non_passported' do
      subject { described_class.new(application_type: :non_passported).config }

      context 'global view of merged config' do
        it 'has all sections from standard and merged configs' do
          expect(subject.keys).to match_array(%i[bank_acct employment applicant new_section])
        end
      end

      context 'existing section in standard config' do
        context 'new attribute block in existing section' do
          it 'has the configurtion from the merged hash' do
            new_attr_block = subject[:bank_acct][:NEW_ATTR_IN_EXISTING_SECTION]
            expect(new_attr_block.keys).to eq %i[value br100_meaning response_type user_defined]
            expect(new_attr_block[:value]).to eq '#new attr in existing section'
            expect(new_attr_block[:br100_meaning]).to eq 'Bank accounts: new attr'
            expect(new_attr_block[:response_type]).to eq 'text'
            expect(new_attr_block[:user_defined]).to eq true
          end
        end

        context 'one value is replaced in an existing attribute block' do
          it 'replaces the one value that has been specified in the merged file and contains all the other originals' do
            modified_attr_block = subject[:bank_acct][:BALANCE]
            expect(modified_attr_block.keys).to eq %i[value br100_meaning response_type user_defined]
            expect(modified_attr_block[:value]).to eq '#new_bank_balance_method'
            expect(modified_attr_block[:br100_meaning]).to eq 'Bank accounts: Current Balance'
            expect(modified_attr_block[:response_type]).to eq 'currency'
            expect(modified_attr_block[:user_defined]).to eq true
          end
        end

        context 'additional value added to existing attribute block' do
          it 'adds the new value and leaves all the other unchanged' do
            modified_attr_block = subject[:bank_acct][:ACCOUNT_NUMBER]
            expect(modified_attr_block.keys).to eq %i[value br100_meaning response_type user_defined generate_block?]
            expect(modified_attr_block[:generate_block?]).to eq false
            expect(modified_attr_block[:value]).to eq '#bank_account_account_number'
            expect(modified_attr_block[:br100_meaning]).to eq 'Bank accounts: Account number'
            expect(modified_attr_block[:response_type]).to eq 'text'
            expect(modified_attr_block[:user_defined]).to eq true
          end
        end
      end

      context 'new section from merged in config' do
        # rubocop:disable Naming/VariableNumber
        it 'is there in its entirety' do
          new_section = subject[:new_section]
          expect(new_section).to eq(
            NEW_SECTION_ATTR_1: {
              value: '#new_section_attr_1',
              br100_meaning: 'Attr 1',
              response_type: 'text',
              user_defined: true
            },
            NEW_SECTION_ATTR: {
              value: '#new_seciton_attr_2',
              br100_meaning: 'Attr 2',
              response_type: 'text',
              user_defined: false
            }
          )
        end
        # rubocop:enable Naming/VariableNumber
      end

      context 'section in standard file but not in merged in file' do
        it 'is there in its entirity' do
          existing_section = subject[:applicant]
          expect(existing_section).to eq(
            NAME: {
              value: '#applicant name',
              br100_meaning: 'Applicant: name',
              response_type: 'text',
              user_defined: false
            },
            AGE: {
              value: '#applicant age',
              br100_meaning: 'Applicant: age',
              response_type: 'number',
              user_defined: true
            }
          )
        end
      end
    end

    context 'standard' do
      subject { described_class.new(application_type: :standard).config }
      it 'returns the existing un-merged hash' do
        expect(subject).to eq YAML.load_file(mock_configuration[:standard]).deep_symbolize_keys
      end
    end

    context 'invalid application type' do
      subject { described_class.new(application_type: :unknown_type).config }
      it 'raises' do
        expect { subject }.to raise_error ArgumentError, 'Invalid application type'
      end
    end

    def mock_configuration
      {
        standard: Rails.root.join('spec/fixtures/files/ccms_keys/standard_ccms_keys.yml'),
        non_passported: Rails.root.join('spec/fixtures/files/ccms_keys/merged_in_ccms_keys.yml')
      }
    end
  end
end
