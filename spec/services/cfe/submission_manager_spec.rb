require "rails_helper"

module CFE
  RSpec.describe SubmissionManager do
    let(:vehicle) { build :vehicle, :populated }
    let(:submission_manager) { described_class.new(application.id) }
    let(:submission) { submission_manager.submission }
    let(:call_result) { true }

    describe ".call", vcr: { record: :new_episodes } do
      let(:staging_host) { "https://check-financial-eligibility-staging.cloud-platform.service.justice.gov.uk" }
      let(:last_submission_history) { SubmissionHistory.order(created_at: :asc).last }

      before do
        allow(Rails.configuration.x).to receive(:check_financial_eligibility_host).and_return(staging_host)
      end

      context "when the application is passported" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_positive_benefit_check_result,
                 :applicant_entering_means,
                 vehicle:)
        end

        it "completes process" do
          described_class.call(application.id)
          expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
        end
      end

      context "when the application is non-passported" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_negative_benefit_check_result,
                 :applicant_entering_means,
                 vehicle:)
        end

        it "completes process" do
          described_class.call(application.id)
          expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
        end
      end
    end

    describe "#call" do
      before do
        allow(CreateAssessmentService).to receive(:call).and_return(true)
        allow(CreateApplicantService).to receive(:call).and_return(true)
        allow(CreateCapitalsService).to receive(:call).and_return(true)
        allow(CreatePropertiesService).to receive(:call).and_return(true)
        allow(CreateVehiclesService).to receive(:call).and_return(true)
        allow(CreateStateBenefitsService).to receive(:call).and_return(true)
        allow(CreateDependantsService).to receive(:call).and_return(true)
        allow(CreateOtherIncomeService).to receive(:call).and_return(true)
        allow(CreateExplicitRemarksService).to receive(:call).and_return(true)
        allow(ObtainAssessmentResultService).to receive(:call).and_return(true)
        allow(CreateIrregularIncomesService).to receive(:call).and_return(true)
        allow(CreateCashTransactionsService).to receive(:call).and_return(true)
      end

      context "with a passported application" do
        let(:application) { create :legal_aid_application, :with_everything, :with_positive_benefit_check_result, :applicant_entering_means, vehicle: }

        it "creates a submission record for the application" do
          expect { submission_manager.call }.to change(application.cfe_submissions, :count).by(1)
        end

        it "calls expected services" do
          expect(CreateAssessmentService).to receive(:call).once
          expect(CreateProceedingTypesService).to receive(:call).once
          expect(CreateApplicantService).to receive(:call).once
          expect(CreateCapitalsService).to receive(:call).once
          expect(CreatePropertiesService).to receive(:call).once
          expect(CreateVehiclesService).to receive(:call).once
          expect(CreateExplicitRemarksService).to receive(:call).once
          expect(ObtainAssessmentResultService).to receive(:call).once

          submission_manager.call
        end

        it "does not call the services only required for non-passported applications" do
          expect(CreateStateBenefitsService).not_to receive(:call)
          expect(CreateDependantsService).not_to receive(:call)
          expect(CreateOtherIncomeService).not_to receive(:call)
          expect(CreateIrregularIncomesService).not_to receive(:call)
          expect(CreateCashTransactionsService).not_to receive(:call)

          submission_manager.call
        end

        context "on submission error" do
          let(:message) { Faker::Lorem.sentence }

          before do
            allow(CreateAssessmentService).to receive(:call).and_raise(SubmissionError, message)
          end

          it "records error in submission" do
            submission_manager.call
            expect(submission.error_message).to eq(message)
            expect(submission).to be_failed
          end

          it "captures error" do
            expect(AlertManager).to receive(:capture_exception).with(message_contains(message))
            submission_manager.call
          end

          context "does not change state if already :failed" do
            before do
              allow(CreateAssessmentService).to receive(:call).and_raise(SubmissionError, message)
              submission.fail!
            end

            it "records error in submission" do
              submission_manager.call
              expect(submission.error_message).to eq(message)
              expect(submission).to be_failed
            end
          end
        end
      end

      context "with a non-passported application" do
        let(:application) { create :legal_aid_application, :with_everything, :with_negative_benefit_check_result, :applicant_entering_means, vehicle: }

        it "creates a submission record for the application" do
          expect { submission_manager.call }.to change(application.cfe_submissions, :count).by(1)
        end

        it "calls expected services" do
          expect(CreateAssessmentService).to receive(:call).once
          expect(CreateProceedingTypesService).to receive(:call).once
          expect(CreateApplicantService).to receive(:call).once
          expect(CreateCapitalsService).to receive(:call).once
          expect(CreatePropertiesService).to receive(:call).once
          expect(CreateVehiclesService).to receive(:call).once
          expect(ObtainAssessmentResultService).to receive(:call).once
          expect(CreateStateBenefitsService).to receive(:call).once
          expect(CreateDependantsService).to receive(:call).once
          expect(CreateOutgoingsService).to receive(:call).once
          expect(CreateOtherIncomeService).to receive(:call).once
          expect(CreateExplicitRemarksService).to receive(:call).once
          expect(CreateIrregularIncomesService).to receive(:call).once
          expect(CreateCashTransactionsService).to receive(:call).once
          expect(CreateEmploymentsService).to receive(:call).once

          submission_manager.call
        end
      end
    end

    describe "#submission" do
      subject(:submission) { described_class.new(application.id).submission }

      let(:application) { create(:legal_aid_application) }

      it "creates and returns submission record for the application" do
        expect { submission }.to change(application.cfe_submissions, :count).by(1)
        expect(submission).to be_a(CFE::Submission)
      end
    end
  end
end
