require "rails_helper"

module CCMS
  module PayloadGenerators
    RSpec.describe EntityAttributesGenerator, :ccms do
      let(:generator) { described_class.new(requestor, xml, entity_name, options) }
      let(:requestor) { instance_double CCMS::Requestors::CaseAddRequestor, submission:, ccms_attribute_keys: yaml_keys }
      let(:submission) { instance_double CCMS::Submission, id: "34343434", legal_aid_application: }
      let(:legal_aid_application) { instance_double LegalAidApplication }
      let(:entity_name) { :bank_acct }
      let(:yaml_keys) { YAML.load_file(Rails.root.join("spec/fixtures/files/ccms_keys/standard_keys.yml")) }
      let(:xml) { instance_double Nokogiri::XML::Builder }
      let(:options) { {} }

      describe "private methods" do
        describe "#extract_response_value" do
          context "when the response_type is text, number, boolean" do
            it "returns config value" do
              config = {
                value: 10,
                br100_meaning: "n/a",
                response_type: "number",
                user_defined: true,
              }
              expect(generator.__send__(:extract_response_value, config)).to eq 10
            end
          end

          it "raises if an unknown response type is given in the config" do
            config = {
              value: 4664,
              br100_meaning: "n/a",
              response_type: "numeric",
              user_defined: true,
            }
            expect {
              generator.__send__(:extract_response_value, config)
            }.to raise_error CCMS::CCMSError, "Submission #{submission.id} - Unknown response type in attributes config yaml file: numeric"
          end

          context "when an exception is raised" do
            before do
              allow_any_instance_of(described_class).to receive(:extract_raw_value).and_raise(TypeError, "type error")
            end

            it "captures the error" do
              config = {
                value: 4664,
                br100_meaning: "n/a",
                response_type: "number",
                user_defined: true,
              }
              expect(AlertManager).to receive(:capture_message).with(/EntityAttributesGenerator TypeError: type error/)
              expect {
                generator.__send__(:extract_response_value, config)
              }.to raise_error TypeError
            end
          end
        end

        describe "#evaluate_generate_block_method?" do
          context "when true" do
            let(:config) { { generate_block?: true } }

            it "returns true" do
              expect(generator.__send__(:evaluate_generate_block_method, config)).to be true
            end
          end

          context "when false" do
            let(:config) { { generate_block?: false } }

            it "returns false" do
              expect(generator.__send__(:evaluate_generate_block_method, config)).to be false
            end
          end

          context "when a method name" do
            let(:dummy_opponent) { instance_double ApplicationMeritsTask::Opponent }
            let(:config)  { { generate_block?: "opponent_full_name" } }
            let(:options) { { opponent: dummy_opponent } }
            let(:expected_result) { "Applicant full-name" }

            it "returns the return value of the method called on the opponent" do
              allow(dummy_opponent).to receive(:full_name).and_return(expected_result)
              expect(generator.__send__(:evaluate_generate_block_method, config)).to eq expected_result
            end
          end
        end
      end
    end
  end
end
