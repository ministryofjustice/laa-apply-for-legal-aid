require "rails_helper"

RSpec.describe CCMS::Submitters::CheckCaseStatusService, :ccms do
  subject(:check_case_status_service) { described_class.new(submission) }

  let(:submission) { create(:submission, :case_submitted) }
  let(:case_add_status_requestor) { instance_double CCMS::Requestors::CaseAddStatusRequestor }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:case_add_status_response) { ccms_data_from_file "case_add_status_response.xml" }
  let(:case_add_status_request) { ccms_data_from_file "case_add_status_request.xml" }

  describe "applicant_submitted state" do
    before do
      allow(CCMS::Requestors::CaseAddStatusRequestor).to receive(:new).and_return(case_add_status_requestor)
    end

    context "when the operation is successful" do
      let(:transaction_request_id_in_example_response) { "20190301030405123456" }
      let(:case_add_status_response_double_response) { false }
      let(:case_add_status_response_double) { instance_double(CCMS::Parsers::CaseAddStatusResponseParser, success?: case_add_status_response_double_response) }

      context "and the case is not yet created" do
        before do
          allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
          allow(case_add_status_requestor).to receive(:call).and_return(case_add_status_response)
          allow(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow(CCMS::Parsers::CaseAddStatusResponseParser).to receive(:new).and_return(case_add_status_response_double)
        end

        context "and poll count remains below limit" do
          it "increments the poll count" do
            expect { check_case_status_service.call }.to change(submission, :case_poll_count).by 1
          end

          it "does not change the state" do
            expect { check_case_status_service.call }.not_to change(submission, :aasm_state)
          end

          it "writes a history record" do
            expect { check_case_status_service.call }.to change(CCMS::SubmissionHistory, :count).by(1)
            expect(history.from_state).to eq "case_submitted"
            expect(history.to_state).to eq "case_submitted"
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it "stores the request body in the submission history record" do
            check_case_status_service.call
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddUpdtStatusRQ",
              transaction_id: "20190101121530123456",
            )
          end

          it "stores the response body in the submission history record" do
            check_case_status_service.call
            expect(history.response).to eq case_add_status_response
          end
        end

        context "and poll count reaches limit" do
          before do
            submission.case_poll_count = CCMS::Submission::POLL_LIMIT - 1
          end

          it "increments the poll count" do
            expect { check_case_status_service.call }.to change(submission, :case_poll_count).by 1
          end

          it "does not change the state" do
            expect { check_case_status_service.call }.not_to change(submission, :aasm_state)
          end

          it "writes a history record" do
            expect { check_case_status_service.call }.to change(CCMS::SubmissionHistory, :count).by(1)
            expect(history.from_state).to eq "case_submitted"
            expect(history.to_state).to eq "failed"
            expect(history.success).to be false
            expect(history.details).to eq "Poll limit exceeded"
          end

          it "stores the reqeust body in the submission history record" do
            check_case_status_service.call
            expect(history.request).to be_soap_envelope_with(
              command: "casebim:CaseAddUpdtStatusRQ",
              transaction_id: "20190101121530123456",
            )
          end

          it "does not store a response body in the submission history record" do
            check_case_status_service.call
            expect(history.response).to be_nil
          end
        end
      end

      context "when the case is created" do
        let(:case_add_status_response_double_response) { true }

        before do
          allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
          allow(case_add_status_requestor).to receive(:call).and_return(case_add_status_response)
          allow(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow(CCMS::Parsers::CaseAddStatusResponseParser).to receive(:new).and_return(case_add_status_response_double)
        end

        it "changes the state to case_created" do
          expect { check_case_status_service.call }.to change(submission, :aasm_state).to "case_created"
        end

        it "writes a history record" do
          expect { check_case_status_service.call }.to change(CCMS::SubmissionHistory, :count).by(1)
          expect(history.from_state).to eq "case_submitted"
          expect(history.to_state).to eq "case_created"
          expect(history.request).to eq case_add_status_request
          expect(history.request).not_to be_nil
          expect(history.success).to be true
          expect(history.details).to be_nil
        end

        it "stores the reqeust body in the submission history record" do
          check_case_status_service.call
          expect(history.request).to be_soap_envelope_with(
            command: "casebim:CaseAddUpdtStatusRQ",
            transaction_id: "20190101121530123456",
          )
        end

        it "stores the response body in the submission history record" do
          check_case_status_service.call
          expect(history.response).to eq case_add_status_response
        end
      end
    end

    context "when the operation is unsuccessful" do
      let(:transaction_request_id_in_example_response) { "20190301030405123456" }
      let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }
      let(:fake_error) { error.sample }

      before do
        allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
        allow(case_add_status_requestor).to receive(:call).and_raise(fake_error, "oops")
        allow(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      end

      it "increments the poll count" do
        expect { check_case_status_service.call }.to raise_error(fake_error, "oops")
        expect(submission.case_poll_count).to eq 1
      end

      it "does not change the state" do
        expect { check_case_status_service.call }.to raise_error(fake_error, "oops")
        expect(submission.aasm_state).to eq "case_submitted"
      end

      it "records the error in the submission history" do
        expect { check_case_status_service.call }.to raise_error(fake_error, "oops")
        expect(CCMS::SubmissionHistory.count).to eq 1
        expect(history.from_state).to eq "case_submitted"
        expect(history.to_state).to eq "failed"
        expect(history.request).to eq case_add_status_request
        expect(history.request).not_to be_nil
        expect(history.success).to be false
        expect(history.details).to match(/#{error}/)
        expect(history.details).to match(/oops/)
      end

      it "stores the reqeust body in the submission history record" do
        expect { check_case_status_service.call }.to raise_error(fake_error, "oops")
        expect(history.request).to be_soap_envelope_with(
          command: "casebim:CaseAddUpdtStatusRQ",
          transaction_id: "20190101121530123456",
        )
      end

      it "does not store the response body in the submission history record" do
        expect { check_case_status_service.call }.to raise_error(fake_error, "oops")
        expect(history.response).to be_nil
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe "#case_add_status_requestor" do
    let(:service_double) { described_class.new(submission) }
    let(:requestor1) { service_double.__send__(:case_add_status_requestor) }
    let(:requestor2) { service_double.__send__(:case_add_status_requestor) }

    it "only instantiates one copy of the CaseAddStatusRequestor" do
      expect(requestor1).to be_instance_of(CCMS::Requestors::CaseAddStatusRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
