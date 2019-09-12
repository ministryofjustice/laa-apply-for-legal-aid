require 'rails_helper'

module CFE
  RSpec.describe SubmissionManager do

    before(:all) do
      VCR.configure { |c| c.ignore_hosts 'localhost' }
    end

    let(:application) { create :legal_aid_application, :with_everything, :at_provider_submitted }

    it 'creates a submission record for the application' do
      expect{
        SubmissionManager.call(application.id)
      }.to change {Submission.count}.by(1)

      submission = Submission.last
      expect(submission.legal_aid_application_id).to eq application.id
      expect(submission.aasm_state).to eq 'applicant_created'
    end

    it 'calls all the services to post data' do
      expect(CreateAssessmentService).to receive(:call).and_call_original
      expect(CreateApplicantService).to receive(:call).and_call_original
      SubmissionManager.call(application.id)
    end
  end
end
