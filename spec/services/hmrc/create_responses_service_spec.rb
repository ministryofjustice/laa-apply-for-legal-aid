require 'rails_helper'

RSpec.describe HMRC::CreateResponsesService do
  subject(:create_service) { described_class.new(legal_aid_application) }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:hmrc_use_dev_mock) { false }

  before do
    allow(HMRC::MockInterfaceResponseService).to receive(:call).and_return({})
    allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_return(hmrc_use_dev_mock)
  end

  describe '#call' do
    subject(:call) { described_class.call(legal_aid_application) }

    context 'when successful' do
      it 'creates two hmrc_response records, one for each use case' do
        expect { call }.to change { legal_aid_application.hmrc_responses.count }.by(2)
      end

      context 'when HMRC_USE_DEV_MOCK is set to false' do
        it 'creates two jobs to request the data and does not invoke the MockInterfaceResponseService' do
          expect { call }.to change(HMRC::SubmissionWorker.jobs, :size).by(2)
          expect(HMRC::MockInterfaceResponseService).to_not have_received(:call)
        end
      end

      context 'when HMRC_USE_DEV_MOCK is set to true' do
        let(:hmrc_use_dev_mock) { 'true' }

        context 'the host is set to' do
          before { allow(HostEnv).to receive(:environment).and_return(host) }

          context 'production' do
            let(:host) { :production }

            it 'creates two jobs to request the data and does not invoke the MockInterfaceResponseService' do
              expect { call }.to change(HMRC::SubmissionWorker.jobs, :size).by(2)
              expect(HMRC::MockInterfaceResponseService).to_not have_received(:call)
            end
          end

          context 'staging' do
            let(:host) { :staging }

            it 'calls the MockInterfaceResponseService and creates no SubmissionWorker jobs' do
              expect { call }.to_not change(HMRC::SubmissionWorker.jobs, :size)
              expect(HMRC::MockInterfaceResponseService).to have_received(:call).twice
            end
          end

          context 'uat' do
            let(:host) { :uat }

            it 'calls the MockInterfaceResponseService and creates no SubmissionWorker jobs' do
              expect { call }.to_not change(HMRC::SubmissionWorker.jobs, :size)
              expect(HMRC::MockInterfaceResponseService).to have_received(:call).twice
            end
          end
        end
      end
    end

    context 'when requests already exist' do
      let!(:hmrc_response) { create :hmrc_response, legal_aid_application: legal_aid_application }

      it 'does not create any more hmrc_response records' do
        expect { call }.not_to change { legal_aid_application.hmrc_responses.count }
      end
      it 'does not create any jobs to request the data' do
        expect { call }.not_to change(HMRC::SubmissionWorker.jobs, :size)
      end
    end
  end
end
