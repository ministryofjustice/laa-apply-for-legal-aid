require 'rails_helper'

module CFE
  RSpec.describe CreateCashTransactionsService do
    let!(:application) { create :legal_aid_application, :with_applicant }
    let!(:benefits) { create :transaction_type, :benefits }
    let!(:friends_or_family) { create :transaction_type, :friends_or_family }
    let!(:maintenance_in) { create :transaction_type, :maintenance_in }
    let!(:benefits1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: benefits }
    let!(:benefits2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: benefits }
    let!(:benefits3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: benefits }
    let!(:friends_or_family1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: friends_or_family }
    let!(:friends_or_family2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: friends_or_family }
    let!(:friends_or_family3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: friends_or_family }
    let!(:maintenance_in1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: maintenance_in }
    let!(:maintenance_in2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: maintenance_in }
    let!(:maintenance_in3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: maintenance_in }
    let!(:child_care) { create :transaction_type, :child_care }
    let!(:legal_aid) { create :transaction_type, :legal_aid }
    let!(:maintenance_out) { create :transaction_type, :maintenance_out }
    let!(:child_care1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: child_care }
    let!(:child_care2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: child_care }
    let!(:child_care3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: child_care }
    let!(:legal_aid1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: legal_aid }
    let!(:legal_aid2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: legal_aid }
    let!(:legal_aid3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: legal_aid }
    let!(:maintenance_out1) { create :cash_transaction, :credit_month1, legal_aid_application: application, transaction_type: maintenance_out }
    let!(:maintenance_out2) { create :cash_transaction, :credit_month2, legal_aid_application: application, transaction_type: maintenance_out }
    let!(:maintenance_out3) { create :cash_transaction, :credit_month3, legal_aid_application: application, transaction_type: maintenance_out }

    let(:submission) { create :cfe_submission, aasm_state: 'irregular_income_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/cash_transactions"
      end
    end

    describe '#request payload' do
      it 'creates the expected payload from the values in the applicant' do
        request_hash = JSON.parse(service.request_body, symbolize_names: true)
        request_hash.each_key do |key|
          expect(request_hash[key]).to match_array(expected_payload_hash[key])
        end
      end
    end

    describe '.call' do
      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context 'successful post' do
        before { stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response) }

        it 'updates the submission record from irregular_income_created to cash_transactions_created' do
          expect(submission.aasm_state).to eq 'irregular_income_created'
          CreateCashTransactionsService.call(submission)
          expect(submission.aasm_state).to eq 'cash_transactions_created'
        end

        it 'creates a submission_history record' do
          expect {
            CreateCashTransactionsService.call(submission)
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

    def expected_payload_hash # rubocop:disable Metrics/AbcSize
      {
        income: [
          {
            category: 'benefits',
            payments: [
              {
                date: benefits3.transaction_date.strftime('%Y-%m-%d'),
                amount: benefits3.amount.abs.to_f,
                client_id: benefits3.id
              },
              {
                date: benefits2.transaction_date.strftime('%Y-%m-%d'),
                amount: benefits2.amount.abs.to_f,
                client_id: benefits2.id
              },
              {
                date: benefits1.transaction_date.strftime('%Y-%m-%d'),
                amount: benefits1.amount.abs.to_f,
                client_id: benefits1.id
              }
            ]
          },
          {
            category: 'friends_or_family',
            payments: [
              {
                date: friends_or_family3.transaction_date.strftime('%Y-%m-%d'),
                amount: friends_or_family3.amount.abs.to_f,
                client_id: friends_or_family3.id
              },
              {
                date: friends_or_family2.transaction_date.strftime('%Y-%m-%d'),
                amount: friends_or_family2.amount.abs.to_f,
                client_id: friends_or_family2.id
              },
              {
                date: friends_or_family1.transaction_date.strftime('%Y-%m-%d'),
                amount: friends_or_family1.amount.abs.to_f,
                client_id: friends_or_family1.id
              }
            ]
          },
          {
            category: 'maintenance_in',
            payments: [
              {
                date: maintenance_in3.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_in3.amount.abs.to_f,
                client_id: maintenance_in3.id
              },
              {
                date: maintenance_in2.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_in2.amount.abs.to_f,
                client_id: maintenance_in2.id
              },
              {
                date: maintenance_in1.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_in1.amount.abs.to_f,
                client_id: maintenance_in1.id
              }
            ]
          }
        ],
        outgoings: [
          {
            category: 'child_care',
            payments: [
              {
                date: child_care3.transaction_date.strftime('%Y-%m-%d'),
                amount: child_care3.amount.abs.to_f,
                client_id: child_care3.id
              },
              {
                date: child_care2.transaction_date.strftime('%Y-%m-%d'),
                amount: child_care2.amount.abs.to_f,
                client_id: child_care2.id
              },
              {
                date: child_care1.transaction_date.strftime('%Y-%m-%d'),
                amount: child_care1.amount.abs.to_f,
                client_id: child_care1.id
              }
            ]
          },
          {
            category: 'legal_aid',
            payments: [
              {
                date: legal_aid3.transaction_date.strftime('%Y-%m-%d'),
                amount: legal_aid3.amount.abs.to_f,
                client_id: legal_aid3.id
              },
              {
                date: legal_aid2.transaction_date.strftime('%Y-%m-%d'),
                amount: legal_aid2.amount.abs.to_f,
                client_id: legal_aid2.id
              },
              {
                date: legal_aid1.transaction_date.strftime('%Y-%m-%d'),
                amount: legal_aid1.amount.abs.to_f,
                client_id: legal_aid1.id
              }
            ]
          },
          {
            category: 'maintenance_out',
            payments: [
              {
                date: maintenance_out3.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_out3.amount.abs.to_f,
                client_id: maintenance_out3.id
              },
              {
                date: maintenance_out2.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_out2.amount.abs.to_f,
                client_id: maintenance_out2.id
              },
              {
                date: maintenance_out1.transaction_date.strftime('%Y-%m-%d'),
                amount: maintenance_out1.amount.abs.to_f,
                client_id: maintenance_out1.id
              }
            ]
          }
        ]
      }
    end

    def dummy_response_hash
      {
        success: true
      }
    end
  end
end
