require 'rails_helper'

module CFE
  RSpec.describe CreateOutgoingsService do
    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, :with_applicant }
    let(:bank_provider) { create :bank_provider, applicant: application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:submission) { create :cfe_submission, aasm_state: 'dependants_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/outgoings"
      end
    end

    describe '.call' do
      before do
        allow_any_instance_of(BankTransaction).to receive(:id).and_return('33333333-3333-3333-3333-333333333333')
        stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response.to_json)
      end

      context 'successful calls' do
        context 'no bank transactions at all' do
          let(:expected_payload_hash) { empty_payload }

          it 'updates the submission record from state_benefits_created to outgoings_created' do
            expect(submission.aasm_state).to eq 'dependants_created'
            described_class.call(submission)
            expect(submission.aasm_state).to eq 'outgoings_created'
          end

          def empty_payload
            {
              outgoings: []
            }
          end
        end

        context 'outgoings bank transactions exist' do
          let(:expected_payload_hash) { payload_with_transactions }

          before { create_bank_transactions }

          it 'updates the submission record from dependants_created to outgoings_created' do
            expect(submission.aasm_state).to eq 'dependants_created'
            described_class.call(submission)
            expect(submission.aasm_state).to eq 'outgoings_created'
          end

          it 'creates a submission_history record' do
            expect {
              described_class.call(submission)
            }.to change { submission.submission_histories.count }.by 1
            history = CFE::SubmissionHistory.last
            expect(history.submission_id).to eq submission.id
            expect(history.url).to eq service.cfe_url
            expect(history.http_method).to eq 'POST'
            expect(history.request_payload).to eq expected_payload_hash.to_json
            expect(history.http_response_status).to eq 200
            expect(history.response_payload).to eq dummy_response.to_json
            expect(history.error_message).to be_nil
          end

          def create_bank_transactions
            Populators::TransactionTypePopulator.call
            create_categorised_bank_transactions
            create_uncategorised_bank_transactions
          end

          def create_categorised_bank_transactions
            create :bank_transaction, :rent_or_mortgage, bank_account: bank_account, happened_at: 10.days.ago, amount: 1150.0
            create :bank_transaction, :rent_or_mortgage, bank_account: bank_account, happened_at: 40.days.ago, amount: 1150.0
            create :bank_transaction, :child_care, bank_account: bank_account, happened_at: 15.days.ago, amount: 234.56
            create :bank_transaction, :child_care, bank_account: bank_account, happened_at: 45.days.ago, amount: 266.0
          end

          def create_uncategorised_bank_transactions
            create :bank_transaction, :debit, bank_account: bank_account, happened_at: 45.days.ago, amount: 266.0 # uncategorised - will be ignored
          end

          def payload_with_transactions
            {
              outgoings: [
                {
                  name: 'child_care',
                  payments: [
                    { payment_date: 45.days.ago.strftime('%F'), amount: 266.0, client_id: '33333333-3333-3333-3333-333333333333' },
                    { payment_date: 15.days.ago.strftime('%F'), amount: 234.56, client_id: '33333333-3333-3333-3333-333333333333' }
                  ]
                },
                {
                  name: 'rent_or_mortgage',
                  payments: [
                    { payment_date: 40.days.ago.strftime('%F'), amount: 1150.0, client_id: '33333333-3333-3333-3333-333333333333' },
                    { payment_date: 10.days.ago.strftime('%F'), amount: 1150.0, client_id: '33333333-3333-3333-3333-333333333333' }
                  ]
                }
              ]
            }
          end
        end
      end

      def dummy_response
        {
          outgoings: [],
          success: true,
          errors: []
        }
      end
    end
  end
end
