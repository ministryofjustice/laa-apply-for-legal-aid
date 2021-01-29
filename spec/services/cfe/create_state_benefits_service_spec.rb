require 'rails_helper'

module CFE
  DAY_SEQUENCE = [10, 40, 70].freeze

  RSpec.describe CreateStateBenefitsService do
    subject(:service) { described_class.new(submission) }

    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, transaction_period_finish_on: Time.zone.today }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'outgoings_created', legal_aid_application: application }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:bank_provider) { create :bank_provider, applicant: applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:non_benefits_bank_transactions) { create_list :bank_transaction, 2, :friends_or_family, bank_account: bank_account }
    let(:benefit) { create :transaction_type, :credit, :benefits }
    let(:dummy_response) { dummy_response_hash.to_json }

    before do
      allow_any_instance_of(BankTransaction).to receive(:id).and_return('22222222-2222-2222-2222-222222222222')
      DAY_SEQUENCE.each do |days|
        create :bank_transaction, :benefits, bank_account: bank_account, amount: '123.45', happened_at: days.days.ago
      end
    end

    describe '.cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/state_benefits"
      end
    end

    describe '.request_body' do
      it 'creates the expected payload from the values in bank_transactions' do
        expect(service.request_body).to include(basic_payload_hash.to_json)
      end

      context 'when a disregarded benefit is recorded' do
        before { create :bank_transaction, :disregarded_benefits, bank_account: bank_account, amount: '123.45', happened_at: DAY_SEQUENCE[0].days.ago }

        it { expect(service.request_body).to include(basic_payload_hash.to_json) }
        it { expect(service.request_body).to include(with_disregarded_hash.to_json) }
        it { expect(application.bank_transactions.count).to eq 6 }
      end

      context 'when a benefit transaction is returned without meta-data' do
        before { create :bank_transaction, :unassigned_benefits, bank_account: bank_account, amount: '123.45', happened_at: DAY_SEQUENCE[0].days.ago }

        it 'raises an error' do
          expect { subject.call }.to raise_error(CFE::SubmissionError, 'Benefit transactions un-coded')
        end
      end

      context 'when a bank transaction is flagged for having multiple benefits' do
        before { create :bank_transaction, :unknown_benefits, :flagged_multi_benefits, bank_account: bank_account, amount: '321.99', happened_at: DAY_SEQUENCE[0].days.ago }

        it { expect(service.request_body).to include(basic_payload_hash.to_json) }
        it { expect(service.request_body).to include(flagged_payload_hash.to_json) }
        it { expect(application.bank_transactions.count).to eq 6 }
      end
    end

    describe '.call' do
      subject(:call_service) { service.call }

      describe 'successful post' do
        before { stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response) }

        it 'updates the submission record from outgoings_created to state_benefits_created' do
          expect(submission.aasm_state).to eq 'outgoings_created'
          call_service
          expect(submission.aasm_state).to eq 'state_benefits_created'
        end

        it 'creates a submission_history record' do
          expect {
            call_service
          }.to change { submission.submission_histories.count }.by 1
          history = CFE::SubmissionHistory.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq service.cfe_url
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload_hash.to_json
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq dummy_response
          expect(history.error_message).to be_nil
        end
      end

      describe 'failed calls to CFE' do
        it_behaves_like 'a failed call to CFE'
      end
    end

    def expected_payload_hash
      { state_benefits: [basic_payload_hash] }
    end

    def with_disregarded_hash
      {
        name: 'grenfell_payments',
        payments: [
          {
            date: DAY_SEQUENCE[0].days.ago.strftime('%Y-%m-%d'),
            amount: 123.45,
            client_id: '22222222-2222-2222-2222-222222222222'
          }
        ]
      }
    end

    def basic_payload_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        name: 'child_benefit',
        payments: [
          {
            date: DAY_SEQUENCE[2].days.ago.strftime('%Y-%m-%d'),
            amount: 123.45,
            client_id: '22222222-2222-2222-2222-222222222222'
          },
          {
            date: DAY_SEQUENCE[1].days.ago.strftime('%Y-%m-%d'),
            amount: 123.45,
            client_id: '22222222-2222-2222-2222-222222222222'
          },
          {
            date: DAY_SEQUENCE[0].days.ago.strftime('%Y-%m-%d'),
            amount: 123.45,
            client_id: '22222222-2222-2222-2222-222222222222'
          }
        ]
      }
    end

    def flagged_payload_hash
      {
        name: 'unknown',
        payments: [
          {
            date: DAY_SEQUENCE[0].days.ago.strftime('%Y-%m-%d'),
            amount: 321.99,
            client_id: '22222222-2222-2222-2222-222222222222',
            flags: { multi_benefit: true }
          }
        ]
      }
    end

    def dummy_response_hash
      {
        objects: [
          {
            id: 'ba43211a-6972-4839-994a-cdd7978c576f',
            gross_income_summary_id: '1a3e0752-4b63-4041-b9d7-f083331f9ab2',
            state_benefit_type_id: '4115b92e-4a2f-4553-9c64-b9c177baf7b4',
            name: 'child_maintenance',
            created_at: '2020-03-27T13:08:22.022Z',
            updated_at: '2020-03-27T13:08:22.022Z',
            monthly_value: '123.45'
          }
        ],
        errors: [],
        success: true
      }
    end
  end
end
