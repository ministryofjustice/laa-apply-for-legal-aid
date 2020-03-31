require 'rails_helper'

module CFE
  RSpec.describe CreateStateBenefitsService do
    subject(:service) { described_class.new(submission) }
    let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, transaction_period_finish_on: Date.today }
    let!(:applicant) { create :applicant, legal_aid_application: application }
    let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_finanical_eligibility_host}/assessments/#{submission.assessment_id}/state_benefit"
      end
    end
  end
end
