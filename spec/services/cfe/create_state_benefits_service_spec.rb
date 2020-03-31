require 'rails_helper'

module CFE
  RSpec.describe CreateStateBenefitsService do
    subject(:service) { described_class.new(submission) }
    let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, transaction_period_finish_on: Date.today, transaction_types: [benefit] }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:bank_provider) { create :bank_provider, applicant: applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:benefits_bank_transaction) { create :bank_transaction, :credit, transaction_type: benefit, bank_account: bank_account }
    let(:benefit) { create :transaction_type, :credit, :benefits }

    it { expect(application.bank_transactions.count).to be_positive }
    it { binding.pry }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_finanical_eligibility_host}/assessments/#{submission.assessment_id}/state_benefit"
      end
    end

    describe '#request_body' do
      it 'creates the expected payload from the values in bank_transactions' do
        expect(service.request_body).to eq expected_payload_hash.to_json
      end
    end

    def expected_payload_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        "state_benefits": [
          {
            "name": 'benefit_type_3',
            "payments": [
              {
                "date": '2019-11-01',
                "amount": 1046.44
              },
              {
                "date": '2019-10-01',
                "amount": 1034.33
              },
              {
                "date": '2019-09-01',
                "amount": 1033.44
              }
            ]
          },
          {
            "name": 'benefit_type_4',
            "payments":
            [
              {
                "date": '2019-11-01',
                "amount": 250.0
              },
              {
                "date": '2019-10-01',
                "amount": 266.02
              },
              {
                "date": '2019-09-01',
                "amount": 250.0
              }
            ]
          }
        ]
      }
    end
  end
end
