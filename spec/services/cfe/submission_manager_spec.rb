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
      let(:last_submission_history) { SubmissionHistory.order(created_at: :asc).last }
      before do
        allow(Rails.configuration.x).to receive(:check_finanical_eligibility_host).and_return(staging_host)
      end

      it 'completes process' do
        described_class.call(application.id)
        expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
      end
    end

    describe '#call' do
      before do
        allow(CreateAssessmentService).to receive(:call).and_return(true)
        allow(CreateApplicantService).to receive(:call).and_return(true)
        allow(CreateCapitalsService).to receive(:call).and_return(true)
        allow(CreatePropertiesService).to receive(:call).and_return(true)
        allow(CreateVehiclesService).to receive(:call).and_return(true)
        allow(ObtainAssessmentResultService).to receive(:call).and_return(true)
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
        expect(ObtainAssessmentResultService).to receive(:call).and_return(true)
        submission_manager.call
      end

      context 'on submission error' do
        let(:message) { Faker::Lorem.sentence }
        before do
          allow(CreateAssessmentService).to receive(:call).and_raise(SubmissionError, message)
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
