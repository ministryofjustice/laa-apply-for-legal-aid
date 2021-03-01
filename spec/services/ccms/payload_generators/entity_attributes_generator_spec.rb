require 'rails_helper'

module CCMS
  module PayloadGenerators
    RSpec.describe EntityAttributesGenerator do
      let(:generator) { described_class.new(requestor, xml, entity_name, options) }
      let(:requestor) { double CCMS::Requestors::CaseAddRequestor, submission: submission, ccms_attribute_keys: yaml_keys }
      let(:submission) { double CCMS::Submission, id: '34343434', legal_aid_application: legal_aid_application }
      let(:legal_aid_application) { double LegalAidApplication }
      let(:entity_name) { :bank_acct }
      let(:yaml_keys) { YAML.load_file(Rails.root.join('spec/fixtures/files/ccms_keys/standard_ccms_keys.yml')) }
      let(:xml) { double Nokogiri::XML::Builder }
      let(:options) { {} }

      context 'private methods' do
        describe '#extract_response_value' do
          context 'response_type is text, number, boolean' do
            it 'returns config value' do
              config = {
                value: 10,
                br100_meaning: 'n/a',
                response_type: 'number',
                user_defined: true
              }
              expect(generator.__send__(:extract_response_value, config)).to eq 10
            end
          end

          it 'raises if an unknown response type is given in the config' do
            config = {
              value: 4664,
              br100_meaning: 'n/a',
              response_type: 'numeric',
              user_defined: true
            }
            expect {
              generator.__send__(:extract_response_value, config)
            }.to raise_error CCMS::CCMSError, "Submission #{submission.id} - Unknown response type in attributes config yaml file: numeric"
          end

          context 'raises exception' do
            before do
              allow_any_instance_of(EntityAttributesGenerator).to receive(:extract_raw_value).and_raise(TypeError, 'type error')
            end
            it 'captures the error' do
              config = {
                value: 4664,
                br100_meaning: 'n/a',
                response_type: 'number',
                user_defined: true
              }
              expect(Sentry).to receive(:capture_message).with(/EntityAttributesGenerator TypeError: type error/)
              expect {
                generator.__send__(:extract_response_value, config)
              }.to raise_error TypeError
            end
          end
        end

        describe '#evaluate_generate_block_method?' do
          context 'when true' do
            let(:config) { { generate_block?: true } }
            it 'returns true' do
              generator.__send__(:evaluate_generate_block_method, config)
            end
          end

          context 'when false' do
            let(:config) { { generate_block?: false } }
            it 'returns false' do
              generator.__send__(:evaluate_generate_block_method, config)
            end
          end

          context 'when a method name' do
            let(:dummy_opponent) { double 'Dummy opponent' }
            let(:config)  { { generate_block?: 'opponent_my_special_method' } }
            let(:options) { { opponent: dummy_opponent } }
            let(:expected_result) { 'result from calling my_special_method on dummy_oppponent' }

            it 'returns the return value of the method called on the opponent' do
              allow(dummy_opponent).to receive(:my_special_method).and_return(expected_result)
              expect(generator.__send__(:evaluate_generate_block_method, config)).to eq expected_result
            end
          end
        end
      end
    end
  end
end
