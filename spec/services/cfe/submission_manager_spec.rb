require "rails_helper"

module CFE
  RSpec.describe SubmissionManager do
    let(:submission_manager) { described_class.new(application.id) }
    let(:submission) { submission_manager.submission }
    let(:call_result) { true }

    describe ".call", vcr: { record: :new_episodes } do
      subject(:call) { described_class.call(application.id) }

      let(:staging_host) { "https://check-financial-eligibility-staging.cloud-platform.service.justice.gov.uk" }
      let(:vehicle) { build(:vehicle, :populated) }
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
          call
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
          call
          expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
        end
      end

      context "when the application is non-passported with bank statement upload" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_proceedings,
                 :with_negative_benefit_check_result,
                 :applicant_entering_means,
                 :with_regular_transactions,
                 vehicle:,
                 attachments: [build(:attachment, :bank_statement)])
        end

        it "completes process" do
          call
          expect(last_submission_history.http_response_status).to eq(200), last_submission_history.inspect
        end
      end
    end

    describe "#call" do
      let(:all_services) do
        passported_services | non_passported_truelayer_services | non_passported_bank_statement_services
      end

      let(:passported_services) do
        [
          CreateAssessmentService,
          CreateProceedingTypesService,
          CreateApplicantService,
          CreateCapitalsService,
          CreateVehiclesService,
          CreatePropertiesService,
          CreateExplicitRemarksService,
          ObtainAssessmentResultService,
        ]
      end

      let(:non_passported_truelayer_services) do
        [
          CreateAssessmentService,
          CreateProceedingTypesService,
          CreateApplicantService,
          CreateCapitalsService,
          CreateVehiclesService,
          CreatePropertiesService,
          CreateExplicitRemarksService,
          CreateDependantsService,
          CreateOutgoingsService,
          CreateStateBenefitsService,
          CreateOtherIncomeService,
          CreateIrregularIncomesService,
          CreateEmploymentsService,
          CreateCashTransactionsService,
          ObtainAssessmentResultService,
        ]
      end

      let(:non_passported_bank_statement_services) do
        [
          CreateAssessmentService,
          CreateProceedingTypesService,
          CreateApplicantService,
          CreateCapitalsService,
          CreateVehiclesService,
          CreatePropertiesService,
          CreateExplicitRemarksService,
          CreateDependantsService,
          CreateIrregularIncomesService,
          CreateEmploymentsService,
          CreateRegularTransactionsService,
          CreateCashTransactionsService,
          ObtainAssessmentResultService,
        ]
      end

      let(:passported_excluded_services) do
        [
          CreateDependantsService,
          CreateOutgoingsService,
          CreateStateBenefitsService,
          CreateOtherIncomeService,
          CreateIrregularIncomesService,
          CreateEmploymentsService,
          CreateRegularTransactionsService,
          CreateCashTransactionsService,
        ]
      end

      let(:bank_statement_excluded_services) do
        [
          CreateOutgoingsService,
          CreateStateBenefitsService,
          CreateOtherIncomeService,
        ]
      end

      before do
        all_services.each do |service|
          allow(service).to receive(:call).and_return(true)
        end
      end

      context "with a passported application" do
        let(:application) { create(:legal_aid_application, :with_everything, :with_positive_benefit_check_result, :applicant_entering_means, :with_vehicle) }

        it "creates a submission record for the application" do
          expect { submission_manager.call }.to change(application.cfe_submissions, :count).by(1)
        end

        it "calls expected services" do
          submission_manager.call

          expect(passported_services).to all(have_received(:call).once)
        end

        it "does not call the services only required for non-passported applications" do
          submission_manager.call

          passported_excluded_services.each do |service|
            expect(service).not_to have_received(:call)
          end
        end
      end

      context "with a non-passported truelayer application" do
        let(:application) { create(:legal_aid_application, :with_everything, :with_negative_benefit_check_result, :applicant_entering_means, :with_vehicle) }

        it "creates a submission record for the application" do
          expect { submission_manager.call }.to change(application.cfe_submissions, :count).by(1)
        end

        it "calls expected services" do
          submission_manager.call

          expect(non_passported_truelayer_services).to all(have_received(:call).once)
        end
      end

      context "with a non-passported bank statement upload application" do
        let(:application) do
          create(:legal_aid_application,
                 :with_everything,
                 :with_negative_benefit_check_result,
                 :applicant_entering_means,
                 attachments: [build(:attachment, :bank_statement)])
        end

        it "creates a submission record for the application" do
          expect { submission_manager.call }.to change(application.cfe_submissions, :count).by(1)
        end

        it "calls expected services" do
          submission_manager.call

          expect(non_passported_bank_statement_services).to all(have_received(:call).once)
        end

        it "does not call services" do
          submission_manager.call

          bank_statement_excluded_services.each do |service|
            expect(service).not_to have_received(:call)
          end
        end
      end

      context "when submission error raised" do
        before do
          allow(CreateAssessmentService)
            .to receive(:call).and_raise(SubmissionError, message)
        end

        let(:application) { create(:legal_aid_application) }
        let(:message) { Faker::Lorem.sentence }

        it "records error in submission" do
          submission_manager.call
          expect(submission.error_message).to eq(message)
          expect(submission).to be_failed
        end

        it "captures error" do
          expect(AlertManager).to receive(:capture_exception).with(message_contains(message))
          submission_manager.call
        end

        context "when state already :failed" do
          before do
            submission.fail!
            allow(CreateAssessmentService).to receive(:call).and_raise(SubmissionError, "my second error")
          end

          it "does not change state from failed" do
            expect { submission_manager.call }.not_to change(submission, :aasm_state).from("failed")
          end

          it "records subsequent error message for submission" do
            submission_manager.call
            expect(submission.error_message).to eq("my second error")
            expect(submission).to be_failed
          end

          it "captures subsequent error" do
            expect(AlertManager).to receive(:capture_exception).with(message_contains("my second error"))
            submission_manager.call
          end
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
