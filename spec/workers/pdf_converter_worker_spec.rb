require "rails_helper"

RSpec.describe PdfConverterWorker, type: :worker do
  subject(:perform) { described_class.new.perform(uuid) }

  let(:uuid) { SecureRandom.uuid }
  let(:worker) { described_class.new }

  it "calls PdfConverter" do
    expect(PdfConverter).to receive(:call).with(uuid)
    perform
  end

  context "when an error occurs" do
    let(:pdf_converter) { class_double PdfConverter }

    before do
      allow(pdf_converter).to receive(:call).with(uuid).and_return(false)
    end

    context "when at ALERT_ON_RETRY_COUNT" do
      before { worker.retry_count = 3 }

      let(:expected_error) do
        <<~MESSAGE
          Attachment id:  failed
          Moving PdfConverterWorker to dead set, it failed with: /An error occurred
        MESSAGE
      end

      it "raises an error" do
        expect { perform }.to raise_error(StandardError)
      end

      it "passes the error to Sentry" do
        described_class.within_sidekiq_retries_exhausted_block do
          expect(Sentry).to receive(:capture_message).with(expected_error)
        end
      end
    end

    context "when at less than ALERT_ON_RETRY_COUNT" do
      before { worker.retry_count = 2 }

      it "raises an error" do
        expect { perform }.to raise_error(StandardError)
      end

      it "does not pass the error to Sentry" do
        expect(Sentry).not_to receive(:capture_message)
      end
    end
  end
end
