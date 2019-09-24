require 'rails_helper'

module CFE
  RSpec.describe SubmissionManager do

    let(:application) { create :legal_aid_application, :with_everything, :at_provider_submitted }
    let(:submission_manager) { described_class.new(application.id) }
    let(:submission) { submission_manager.submission }
    let(:call_result) { true }

    before do
      allow(CreateAssessmentService).to receive(:call).and_return(true)
      allow(CreateApplicantService).to receive(:call).and_return(true)
      allow(CreateCapitalsService).to receive(:call).and_return(true)
      allow(CreatePropertiesService).to receive(:call).and_return(true)
      allow(CreateVehiclesService).to receive(:call).and_return(true)
    end

    describe '#call' do
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
