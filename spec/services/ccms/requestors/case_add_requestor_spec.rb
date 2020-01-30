# add_case_requestor_spec.rb
require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe CaseAddRequestor do
      describe '#call' do
        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_proceeding_types,
                 :with_everything,
                 :with_applicant_and_address,
                 :with_positive_benefit_check_result,
                 :with_substantive_scope_limitation,
                 populate_vehicle: true,
                 office: office
        end
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_result, submission: cfe_submission }
        let(:office) { create :office }
        let(:requestor) { described_class.new(submission, {}) }
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_case_application }
        let(:expected_xml) { requestor.__send__(:request_xml) }

        before do
          Timecop.freeze
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
        end

        it 'calls the savon soap client' do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          requestor.call
        end
      end

      context 'private_methods' do
        let(:options) { {} }
        let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, populate_vehicle: true }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
        let(:requestor) { described_class.new(submission, {}) }
        context '#extract_response_value' do
          it 'raises if an unknown response type is given in the config' do
            config = {
              value: 4664,
              br100_meaning: 'n/a',
              response_type: 'numeric',
              user_defined: true
            }
            expect {
              requestor.__send__(:extract_response_value, config, options)
            }.to raise_error CCMS::CcmsError, "Submission #{submission.id} - Unknown response type: numeric"
          end
        end

        describe '#evaluate_generate_block_method?' do
          context 'when true' do
            let(:config) { { generate_block?: true } }
            it 'returns true' do
              requestor.__send__(:evaluate_generate_block_method, config, options)
            end
          end

          context 'when false' do
            let(:config) { { generate_block?: false } }
            it 'returns false' do
              requestor.__send__(:evaluate_generate_block_method, config, options)
            end
          end

          context 'when a method name' do
            let(:dummy_opponent) { double 'Dummy opponent' }
            let(:config)  { { generate_block?: 'opponent_my_special_method' } }
            let(:options) { { opponent: dummy_opponent } }
            let(:expected_result) { 'result from calling my_special_method on dummy_oppponent' }

            it 'returns the return value of the method called on the opponent' do
              allow(dummy_opponent).to receive(:my_special_method).and_return(expected_result)
              expect(requestor.__send__(:evaluate_generate_block_method, config, options)).to eq expected_result
            end
          end
        end
      end
    end
  end
end
