require 'rails_helper'

module CFE
  RSpec.describe CreateOtherIncomeService do
    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, :with_applicant }
    let(:bank_provider) { create :bank_provider, applicant: application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:submission) { create :cfe_submission, aasm_state: 'state_benefits_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }
    let(:today) { Time.zone.today.strftime('%Y-%m-%d') }
    let(:one_week_ago) { 1.week.ago.strftime('%Y-%m-%d') }
    let(:two_weeks_ago) { 2.weeks.ago.strftime('%Y-%m-%d') }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/other_incomes"
      end
    end

    describe '.call' do
      before do
        allow_any_instance_of(BankTransaction).to receive(:id).and_return('11111111-1111-1111-1111-111111111111')
        stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response)
      end

      context 'successful calls' do
        context 'no bank transactions at all' do
          describe 'successful calls' do
            let(:expected_payload_hash) { empty_payload }

            it 'updates the submission record from state_benefits_created to other_income_created' do
              expect(submission.aasm_state).to eq 'state_benefits_created'
              described_class.call(submission)
              expect(submission.aasm_state).to eq 'other_income_created'
            end
          end

          context 'no other income bank transactions' do
            let(:expected_payload_hash) { empty_payload }

            before { create_non_other_income_bank_transactions }

            it 'updates the submission record from state_benefits_created to other_income_created' do
              expect(submission.aasm_state).to eq 'state_benefits_created'
              described_class.call(submission)
              expect(submission.aasm_state).to eq 'other_income_created'
            end
          end

          context 'other_income bank transactions' do
            let(:expected_payload_hash) { loaded_payload }

            before { create_other_income_bank_transactions }

            it 'updates the submission record from state_benefits_created to other_income_created' do
              expect(submission.aasm_state).to eq 'state_benefits_created'
              described_class.call(submission)
              expect(submission.aasm_state).to eq 'other_income_created'
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
              expect(history.response_payload).to eq dummy_response
              expect(history.error_message).to be_nil
            end
          end
        end
      end

      context 'failed calls to CFE' do
        let(:expected_payload_hash) { loaded_payload }
        it_behaves_like 'a failed call to CFE'
      end
    end

    def dummy_response_hash
      {
        objects: [
          {
            id: '6027b85f-d286-48b6-94ff-c191bf71dedb',
            gross_income_summary_id: '4499dd19-f407-4ddd-9edb-6c30f567c629',
            name: 'Student grant',
            created_at: '2020-03-27T13:08:21.889Z',
            updated_at: '2020-03-27T13:08:21.889Z',
            monthly_income: nil,
            assessment_error: false
          },
          {
            id: '7c82b3a7-7563-400e-809e-8c7ce7dad3c4',
            gross_income_summary_id: '4499dd19-f407-4ddd-9edb-6c30f567c629',
            name: 'Help from family',
            created_at: '2020-03-27T13:08:21.907Z',
            updated_at: '2020-03-27T13:08:21.907Z',
            monthly_income: nil,
            assessment_error: false
          }
        ],
        errors: [],
        success: true
      }
    end

    def empty_payload
      {
        other_incomes: []
      }
    end

    def loaded_payload
      {
        other_incomes: [
          {
            source: 'Friends or family',
            payments: [
              { date: one_week_ago, amount: 60.0, client_id: '11111111-1111-1111-1111-111111111111' },
              { date: today, amount: 60.0, client_id: '11111111-1111-1111-1111-111111111111' }
            ]
          },
          {
            source: 'Maintenance in',
            payments: [
              { date: one_week_ago, amount: 125.0, client_id: '11111111-1111-1111-1111-111111111111' },
              { date: today, amount: 250.0, client_id: '11111111-1111-1111-1111-111111111111' }
            ]
          },
          {
            source: 'Student loan',
            payments: [
              { date: two_weeks_ago, amount: 355.68, client_id: '11111111-1111-1111-1111-111111111111' },
              { date: one_week_ago, amount: 355.67, client_id: '11111111-1111-1111-1111-111111111111' },
              { date: today, amount: 355.66, client_id: '11111111-1111-1111-1111-111111111111' }
            ]
          }
        ]
      }
    end

    def create_non_other_income_bank_transactions
      Populators::TransactionTypePopulator.call
      create :bank_transaction, :benefits, bank_account: bank_account
      create :bank_transaction, :child_care, bank_account: bank_account
      create :bank_transaction, :rent_or_mortgage, bank_account: bank_account
    end

    def create_other_income_bank_transactions
      create_non_other_income_bank_transactions

      create_series_of_bank_transaction :maintenance_in, bank_account, [250.0, 125.0]
      create_series_of_bank_transaction :friends_or_family, bank_account, [60.0, 60.0]
      create_series_of_bank_transaction :student_loan, bank_account, [355.66, 355.67, 355.68]
    end

    def create_series_of_bank_transaction(trait, bank_account, amounts)
      amounts.each_with_index do |amount, index|
        create :bank_transaction, trait, bank_account: bank_account, amount: amount, happened_at: index.weeks.ago
      end
    end
  end
end
