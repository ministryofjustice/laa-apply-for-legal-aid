require "rails_helper"

RSpec.describe HMRC::ResultWorker do
  subject(:worker) { described_class.new }

  let(:application) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
  let(:applicant) { application.applicant }
  let(:hmrc_response) do
    create(:hmrc_response, :use_case_one, :in_progress, legal_aid_application: application,
                                                        response: nil, owner_id: applicant.id, owner_type: applicant.class)
  end

  describe ".perform" do
    subject(:perform) { worker.perform(hmrc_response.id) }

    context "when submission has completed" do
      let(:good_response) do
        {
          "data" => [
            { "correlation_id" => hmrc_response.submission_id },
            {
              "individuals/matching/individual" => {
                "firstName" => "fname",
                "lastName" => "lname",
                "nino" => "XY234567A",
                "dateOfBirth" => "1992-07-22",
              },
            },
            { "income/paye/paye" => { "income" => [] } },
            { "income/sa/selfAssessment" => [] },
            { "income/sa/pensions_and_state_benefits/selfAssessment" => [] },
            { "income/sa/source/selfAssessment" => [] },
            { "income/sa/employments/selfAssessment" => [] },
            { "income/sa/additional_information/selfAssessment" => [] },
            { "income/sa/partnerships/selfAssessment" => [] },
            { "income/sa/uk_properties/selfAssessment" => [] },
            { "income/sa/foreign/selfAssessment" => [] },
            { "income/sa/further_details/selfAssessment" => [] },
            { "income/sa/interests_and_dividends/selfAssessment" => [] },
            { "income/sa/other/selfAssessment" => [] },
            { "income/sa/summary/selfAssessment" => [] },
            { "income/sa/trusts/selfAssessment" => [] },
            { "employments/paye/employments" => [] },
            { "benefits_and_credits/working_tax_credit/applications" => [] },
            { "benefits_and_credits/child_tax_credit/applications" => [] },
          ],
        }
      end

      before do
        allow(HMRC::Interface::ResultService).to receive(:call).with(hmrc_response).and_return(good_response)
        allow(HMRC::ParsedResponse::Persistor).to receive(:call).with(hmrc_response).and_return(true)
      end

      it "returns the expected payload" do
        perform
        expect(hmrc_response.reload.response).to eq good_response
        expect(HMRC::ParsedResponse::Persistor).to have_received(:call)
      end
    end

    context "when the submission is still in progress" do
      let(:in_progress_response) do
        {
          submission: hmrc_response.submission_id,
          status: "processing",
          _links: [
            {
              href: "https://main-laa-hmrc-interface-uat.cloud-platform.service.justice.gov.uk/api/v1/submission/status/#{hmrc_response.submission_id}",
            },
          ],
        }
      end

      before do
        allow(HMRC::Interface::ResultService).to receive(:call).with(hmrc_response).and_return(in_progress_response)
      end

      it "raises a silently trapped error and does not change the response" do
        expect { perform }.to raise_error(HMRC::SentryIgnoreThisSidekiqFailError)
        expect(hmrc_response.reload.response).to be_nil
      end
    end

    context "when an error occurs" do
      let(:hmrc_interface_service) { class_double HMRC::Interface::ResultService }

      before do
        allow(hmrc_interface_service).to receive(:call).and_raise(HMRC::InterfaceError)
      end

      context "when @retry_count is" do
        context "when below the halfway point" do
          before { worker.retry_count = 4 }

          it "raises an error but does not pass it to sentry" do
            expect(Sentry).not_to receive(:capture_message)
            expect { perform }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context "when at the halfway point" do
          before { worker.retry_count = 5 }

          it "raises an error but does not pass it to sentry" do
            expect(Sentry).not_to receive(:capture_message)
            expect { perform }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context "when one above the halfway point" do
          before { worker.retry_count = 6 }

          let(:expected_error) do
            <<~MESSAGE
              HMRC result check for id: #{hmrc_response.id} is failing, retry count at #{worker.retry_count}
            MESSAGE
          end

          it "raises a sentry warning and an untracked error" do
            expect(Sentry).to receive(:capture_message).with(expected_error)
            expect { perform }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context "when above the halfway point" do
          before { worker.retry_count = 7 }

          it "raises an error but does not pass it to sentry" do
            expect(Sentry).not_to receive(:capture_message)
            expect { perform }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context "when at MAX_RETRIES" do
          before { worker.retry_count = 10 }

          let(:expected_error) do
            <<~MESSAGE
              HMRC result check for id:  failed
              Moving HMRC::ResultWorker to dead set, it failed with: /An error occurred
            MESSAGE
          end

          it "raises a tracked error and the expired block" do
            described_class.within_sidekiq_retries_exhausted_block do
              expect(Sentry).to receive(:capture_message).with(expected_error)
            end
            expect { perform }.to raise_error HMRC::InterfaceError
          end
        end
      end
    end
  end
end
