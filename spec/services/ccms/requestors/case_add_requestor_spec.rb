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
        let!(:cfe_result) { create :cfe_v2_result, submission: cfe_submission }
        let(:office) { create :office }
        let(:requestor) { described_class.new(submission, {}) }
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_case_application }
        let(:expected_xml) { requestor.__send__(:request_xml) }

        before do
          freeze_time
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
        end

        it 'calls the savon soap client' do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          requestor.call
        end
      end
    end
  end
end
