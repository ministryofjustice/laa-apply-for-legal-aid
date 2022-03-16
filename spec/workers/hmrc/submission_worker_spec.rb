require 'rails_helper'

RSpec.describe HMRC::SubmissionWorker do
  subject(:worker) { described_class.new }

  let(:application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:hmrc_response) { create(:hmrc_response, :use_case_one, legal_aid_application: application) }

  it { is_expected.to be_a described_class }

  describe '.perform' do
    subject(:perform) { worker.perform(hmrc_response.id) }

    context 'when successful' do
      let(:good_response) do
        {
          id: '0039163e-7321-4c34-81eb-d740657a88ec',
          _links: [
            {
              href: 'https://main-laa-hmrc-interface-uat.cloud-platform.service.justice.gov.uk/api/v1/submission/status/26b94ef2-5854-409a-8223-05f4b58368b7'
            }
          ]
        }
      end
      before do
        allow(HMRC::Interface::SubmissionService).to receive(:call).with(hmrc_response).and_return(good_response)
      end

      it 'updates the hmrc_response' do
        perform
        expect(hmrc_response.reload.url).to eq good_response[:_links][0][:href]
        expect(hmrc_response.reload.submission_id).to eq good_response[:id]
      end

      it 'starts a new check job' do
        expect { perform }.to change(HMRC::ResultWorker.jobs, :size).by(1)
      end
    end

    context 'when an error occurs' do
      let(:hmrc_interface_service) { class_double HMRC::Interface::SubmissionService }
      before do
        allow(hmrc_interface_service).to receive(:call).and_raise(HMRC::InterfaceError)
      end
      context 'when @retry_count is' do
        context 'below the halfway point' do
          before { worker.retry_count = 4 }

          it 'raises an error but does not pass it to sentry' do
            expect(Sentry).not_to receive(:capture_message)
            expect { subject }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context 'on the halfway point' do
          before { worker.retry_count = 5 }

          it 'raises an error but does not pass it to sentry' do
            expect(Sentry).not_to receive(:capture_message)
            expect { subject }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context 'one above the halfway point' do
          before { worker.retry_count = 6 }
          let(:expected_error) do
            <<~MESSAGE
              HMRC submission id: #{hmrc_response.id} is failing, retry count at #{worker.retry_count}
            MESSAGE
          end

          it 'raises a sentry warning and an untracked error' do
            expect(Sentry).to receive(:capture_message).with(expected_error)
            expect { subject }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context 'above the halfway point' do
          before { worker.retry_count = 7 }

          it 'raises an error but does not pass it to sentry' do
            expect(Sentry).not_to receive(:capture_message)
            expect { subject }.to raise_error HMRC::SentryIgnoreThisSidekiqFailError
          end
        end

        context 'at MAX_RETRIES' do
          before { worker.retry_count = 10 }

          let(:expected_error) do
            <<~MESSAGE
              HMRC submission id:  failed
              Moving HMRC::SubmissionWorker to dead set, it failed with: /An error occured
            MESSAGE
          end

          it 'raises a tracked error and the expired block' do
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
