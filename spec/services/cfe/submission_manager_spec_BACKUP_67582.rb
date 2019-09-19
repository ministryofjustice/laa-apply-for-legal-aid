require 'rails_helper'

module CFE
  RSpec.describe SubmissionManager do
    let(:vehicle) { build :vehicle, :populated }
    let(:application) { create :legal_aid_application, :with_everything, :at_provider_submitted, vehicle: vehicle }
    let(:submission_manager) { described_class.new(application.id) }
    let(:submission) { submission_manager.submission }
    let(:call_result) { true }

    describe '.call', vcr: { record: :new_episodes } do
      let(:staging_host) { 'https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk' }
      let(:last_submission_history) { CFE::SubmissionHistory.order(created_at: :asc).last }
      before do
<<<<<<< HEAD
        allow(Rails.configuration.x).to receive(:check_finanical_eligibility_host).and_return(staging_host)
      end

      it 'completes process' do
        described_class.call(application.id)
        expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
=======
        allow_any_instance_of(CreateAssessmentService).to receive(:post_request).and_return(assessment_response)
        allow_any_instance_of(CreateApplicantService).to receive(:post_request).and_return(generic_successful_response)
        allow_any_instance_of(CreateCapitalsService).to receive(:post_request).and_return(generic_successful_response)
        allow_any_instance_of(CreateVehiclesService).to receive(:post_request).and_return(generic_successful_response)
        allow_any_instance_of(ObtainAssessmentResultService).to receive(:query_cfe_service).and_return(generic_successful_response)
      end

      it 'creates a submission record for the application' do
        expect {
          SubmissionManager.call(application.id)
        }.to change { Submission.count }.by(1)

        submission = Submission.last

        expect(submission.legal_aid_application_id).to eq application.id
        expect(submission.aasm_state).to eq 'results_obtained' # TODO: change this as we add more services to the test
      end

      it 'calls all the services to post data' do
        expect(CreateAssessmentService).to receive(:call).and_call_original
        expect(CreateApplicantService).to receive(:call).and_call_original
        expect(CreateCapitalsService).to receive(:call).and_call_original
        expect(CreateVehiclesService).to receive(:call).and_call_original
        expect(ObtainAssessmentResultService).to receive(:call).and_call_original

        # TODO: Add these expectations as we add more services to the test
        # expect(CreatePropertiesService).to receive(:call).and_call_original

        SubmissionManager.call(application.id)
      end

      it 'writes the expected submission history records' do
        expect {
          SubmissionManager.call(application.id)
        }.to change { SubmissionHistory.count }.by 5 # TODO: increase this number as we add more services to the spec
>>>>>>> AP-942 Get Assessment results from CFE service
      end
    end

    describe '#call' do
      before do
        allow(CreateAssessmentService).to receive(:call).and_return(true)
        allow(CreateApplicantService).to receive(:call).and_return(true)
        allow(CreateCapitalsService).to receive(:call).and_return(true)
        allow(CreatePropertiesService).to receive(:call).and_return(true)
        allow(CreateVehiclesService).to receive(:call).and_return(true)
      end

      it 'creates a submission record' do
        expect { submission_manager.call }.to change { Submission.count }.by(1)
      end

      it 'calls all the services it manages' do
        expect(CreateAssessmentService).to receive(:call).and_return(true)
        expect(CreateApplicantService).to receive(:call).and_return(true)
        expect(CreateCapitalsService).to receive(:call).and_return(true)
        expect(CreatePropertiesService).to receive(:call).and_return(true)
        expect(CreateVehiclesService).to receive(:call).and_return(true)

        # TODO: Add these expectations as we add more services to the test
        # expect(ObtainResultsService).to receive(:call).and_return(true)

        submission_manager.call
      end

      context 'on submission error' do
        let(:message) { Faker::Lorem.sentence }
        before do
          allow(CreateAssessmentService).to receive(:call).and_raise(CFE::SubmissionError, message)
        end

        it 'records error in submission' do
          submission_manager.call
          expect(submission.error_message).to eq(message)
          expect(submission).to be_failed
        end
      end
    end

    describe '#submission' do
      it 'associates the application with the submission' do
        expect(submission.legal_aid_application_id).to eq application.id
      end
    end
  end
end
