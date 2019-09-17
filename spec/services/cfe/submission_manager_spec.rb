require 'rails_helper'

module CFE
  RSpec.describe SubmissionManager do
    # before(:all) do
    #   VCR.configure { |c| c.ignore_hosts 'localhost' }
    # end

    let(:application) { create :legal_aid_application, :with_everything, :at_provider_submitted }

    context 'No Errors' do
      before do
        allow_any_instance_of(CreateAssessmentService).to receive(:post_request).and_return(assessment_response)
        allow_any_instance_of(CreateApplicantService).to receive(:post_request).and_return(applicant_response)
      end

      it 'creates a submission record for the application' do
        expect {
          SubmissionManager.call(application.id)
        }.to change { Submission.count }.by(1)

        submission = Submission.last
        expect(submission.legal_aid_application_id).to eq application.id
        expect(submission.aasm_state).to eq 'applicant_created' # TODO: change this as we add more services to the test
      end

      it 'calls all the services to post data' do
        expect(CreateAssessmentService).to receive(:call).and_call_original
        expect(CreateApplicantService).to receive(:call).and_call_original

        # TODO: Add these expectations as we add more services to the test
        # expect(CreateCapitalsService).to receive(:call).and_call_original
        # expect(CreatePropertiesService).to receive(:call).and_call_original
        # expect(CreateVehiclesService).to receive(:call).and_call_original
        # expect(ObtainResultsService).to receive(:call).and_call_original

        SubmissionManager.call(application.id)
      end

      it 'writes the expected submission history records' do
        expect {
          SubmissionManager.call(application.id)
        }.to change { SubmissionHistory.count }.by 2 # TODO: increase this number as we add more services to the spec
      end
    end

    context 'exception raised' do
      before do
        allow_any_instance_of(CreateAssessmentService).to receive(:post_request).and_return(assessment_response)
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::ConnectionFailed.new('my test error'))
      end

      it 'transitions the aasm state to failed with an error message' do
        SubmissionManager.call(application.id)
        submission = CFE::Submission.last
        expect(submission).to be_failed
        expect(submission.error_message).to eq 'CFE::CreateApplicantService received Faraday::ConnectionFailed: my test error'
      end

      it 'creates two submission history records' do
        expect {
          SubmissionManager.call(application.id)
        }.to change { SubmissionHistory.count }.by 2
      end

      it 'writes error message and backtrace in submission history for create_applicants' do
        SubmissionManager.call(application.id)
        submission = CFE::Submission.last
        history = submission.submission_histories.find_by(url: "http://localhost:3001/assessments/#{submission.assessment_id}/applicant")
        expect(history.http_response_status).to be_nil
        expect(history.error_message).to eq 'CFE::CreateApplicantService received Faraday::ConnectionFailed: my test error'
        expect(history.error_backtrace).not_to be_nil
      end
    end

    def assessment_response
      double Faraday::Response, status: 200, body: dummy_assessment_body
    end

    def dummy_assessment_body
      {
        'success' => true,
        'objects' => [
          {
            'id' => '1b2aa5eb-3763-445e-9407-2397ec3968f6'
          }
        ]
      }.to_json
    end

    def applicant_response
      double Faraday::Response, status: 200, body: dummy_applicant_response
    end

    def dummy_applicant_response
      {
        'success' => true
      }.to_json
    end
  end
end
