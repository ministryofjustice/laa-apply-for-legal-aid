require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe CaseAddRequestor do
      describe '#call' do
        let(:expected_tx_id) { '202011241154290000006983477' }

        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_positive_benefit_check_result,
                 :with_proceeding_type_and_scope_limitations,
                 this_proceeding_type: proceeding_type,
                 substantive_scope_limitation: scope_limitation,
                 applicant: applicant,
                 vehicle: vehicle,
                 other_assets_declaration: other_assets_declaration,
                 savings_amount: savings_amount,
                 provider: provider,
                 opponent: opponent,
                 office: office
        end
        let(:applicant) do
          create :applicant,
                 :with_address,
                 first_name: 'Shery',
                 last_name: 'Ledner',
                 national_insurance_number: 'EG587804M',
                 date_of_birth: Date.new(1977, 4, 10),
                 address: address
        end
        let!(:chances_of_success) do
          create :chances_of_success, :with_optional_text, application_proceeding_type: legal_aid_application.lead_application_proceeding_type
        end
        let(:vehicle) { create :vehicle, estimated_value: 3030, payment_remaining: 881, purchased_on: Date.new(2008, 8, 22), used_regularly: true }
        let(:other_assets_declaration) do
          create :other_assets_declaration,
                 valuable_items_value: 144_524.74,
                 money_owed_value: 100,
                 inherited_assets_value: 200,
                 land_value: 300,
                 timeshare_property_value: 400,
                 second_home_value: 500,
                 trust_value: 600
        end
        let(:scope_limitation) { create :scope_limitation, code: 'AA001', description: 'Temporibus illum modi. Enim exercitationem nemo. In ut quia.' }
        let(:address) { create :address, postcode: 'GH08NY' }
        let(:provider) { create :provider, username: 'saturnina', firm: firm, email: 'patrick_rath@example.net' }
        let(:firm) { create :firm, ccms_id: 169 }
        let(:proceeding_type) { create :proceeding_type, :with_real_data }
        let(:opponent) { create :opponent, police_notified: true }
        let(:submission) { create :submission, :case_ref_obtained, case_ccms_reference: '300000000001', legal_aid_application: legal_aid_application }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
        let(:office) { create :office, ccms_id: '4727432767' }
        let(:savings_amount) { create :savings_amount, :all_nil }
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_case_application }
        let(:expected_xml) { requestor.__send__(:request_xml) }
        let(:requestor) { described_class.new(submission, {}) }

        before do
          allow(Rails.configuration.x.ccms_soa).to receive(:client_username).and_return('FakeUser')
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password).and_return('FakePassword')
          allow(Rails.configuration.x.ccms_soa).to receive(:client_password_type).and_return('password_type')
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          allow(legal_aid_application).to receive(:calculation_date).and_return(Date.new(2020, 3, 25))
        end

        it 'calls the savon soap client' do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
          requestor.call
        end

        it 'generates the expected xml' do
          travel_to Time.zone.parse('2020-11-24T11:54:29.000') do
            test_data_xml = ccms_data_from_file 'case_add_request.xml'
            expect(expected_xml).to eq test_data_xml
          end
        end
      end
    end
  end
end
