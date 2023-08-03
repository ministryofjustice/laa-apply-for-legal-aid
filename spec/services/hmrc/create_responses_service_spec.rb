require "rails_helper"

RSpec.describe HMRC::CreateResponsesService do
  subject(:create_service) { described_class.new(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_transaction_period) }
  let(:hmrc_use_dev_mock) { false }

  before do
    allow(HMRC::MockInterfaceResponseService).to receive(:call).and_return({})
    allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_return(hmrc_use_dev_mock)
  end

  describe "#call" do
    subject(:call) { described_class.call(legal_aid_application) }

    context "when successful" do
      it "creates two hmrc_response records, one for each use case" do
        expect { call }.to change { legal_aid_application.hmrc_responses.count }.by(2)
      end

      it "adds the applicant as owner to each response record created" do
        legal_aid_application.reload.hmrc_responses.each do |response|
          expect(response.owner_id).to eq(legal_aid_application.applicant.id)
          expect(response.owner_type).to eq(legal_aid_application.applicant.class)
        end
      end

      context "when HMRC_USE_DEV_MOCK is set to false" do
        it "creates two jobs to request the data and does not invoke the MockInterfaceResponseService" do
          expect { call }.to change(HMRC::SubmissionWorker.jobs, :size).by(2)
          expect(HMRC::MockInterfaceResponseService).not_to have_received(:call)
        end
      end

      context "when HMRC_USE_DEV_MOCK is set to true" do
        let(:hmrc_use_dev_mock) { "true" }

        before { allow(HostEnv).to receive(:environment).and_return(host) }

        context "and the host is set to production" do
          let(:host) { :production }

          it "creates two jobs to request the data and does not invoke the MockInterfaceResponseService" do
            expect { call }.to change(HMRC::SubmissionWorker.jobs, :size).by(2)
            expect(HMRC::MockInterfaceResponseService).not_to have_received(:call)
          end
        end

        context "and the host is set to staging" do
          let(:host) { :staging }

          it "calls the MockInterfaceResponseService and creates no SubmissionWorker jobs" do
            expect { call }.not_to change(HMRC::SubmissionWorker.jobs, :size)
            expect(HMRC::MockInterfaceResponseService).to have_received(:call).twice
          end
        end

        context "and the host is set to uat" do
          let(:host) { :uat }

          it "calls the MockInterfaceResponseService and creates no SubmissionWorker jobs" do
            expect { call }.not_to change(HMRC::SubmissionWorker.jobs, :size)
            expect(HMRC::MockInterfaceResponseService).to have_received(:call).twice
          end
        end
      end
    end

    context "when successful and applicant has a partner with an NI number" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_transaction_period) }

      it "creates four hmrc_response records, one for each use case for each individual" do
        expect { call }.to change { legal_aid_application.hmrc_responses.count }.by(4)
        expect(legal_aid_application.applicant.hmrc_responses.count).to eq 2
        expect(legal_aid_application.partner.hmrc_responses.count).to eq 2
      end

      it "adds the applicant as owner to each response record created" do
        legal_aid_application.applicant.reload.hmrc_responses.each do |response|
          expect(response.owner_id).to eq(legal_aid_application.applicant.id)
          expect(response.owner_type).to eq(legal_aid_application.applicant.class)
        end
      end

      it "adds the partner as owner to each response record created" do
        legal_aid_application.partner.reload.hmrc_responses.each do |response|
          expect(response.owner_id).to eq(legal_aid_application.partner.id)
          expect(response.owner_type).to eq(legal_aid_application.partner.class)
        end
      end
    end

    context "when requests already exist" do
      let(:applicant) { legal_aid_application.applicant }
      let!(:hmrc_response) { create(:hmrc_response, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class) }

      it "does not create any more hmrc_response records" do
        expect { call }.not_to change { legal_aid_application.hmrc_responses.count }
      end

      it "does not create any jobs to request the data" do
        expect { call }.not_to change(HMRC::SubmissionWorker.jobs, :size)
      end
    end
  end
end
