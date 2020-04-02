require 'rails_helper'

module CFE
  RSpec.describe CreateOtherIncomeService do
    let(:application) { create :legal_aid_application, :with_negative_benefit_check_result, :with_applicant }
    let(:bank_provider) { create :bank_provider, applicant: application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:submission) { create :cfe_submission, aasm_state: 'state_benefits_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_finanical_eligibility_host}/assessments/#{submission.assessment_id}/other_income"
      end
    end

    describe '.call' do
      before { stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response) }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context 'no bank transactions' do
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
      end
    end

    def dummy_response_hash
      {
        "success": true
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
            :source=>"student_loan",
            :payments=> [
              {:date=>"2020-03-19", :amount=>355.68},
              {:date=>"2020-03-26", :amount=>355.67},
              {:date=>"2020-04-02", :amount=>355.66}
            ]
          },
          {
            :source=>"friends_or_family",
            :payments=> [
              {:date=>"2020-03-26", :amount=>60.0},
              {:date=>"2020-04-02", :amount=>60.0}
            ]
          },
          {
            :source=>"maintenance_in",
            :payments=> [
              {:date=>"2020-03-26", :amount=>125.0},
              {:date=>"2020-04-02", :amount=>250.0}
            ]
          }
        ]
      }
    end

    def create_non_other_income_bank_transactions
      TransactionType.populate
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


