require "rails_helper"

RSpec.describe PDFConverterWorker, type: :worker do
  subject(:perform) { instance.perform(uuid) }

  let(:instance) { described_class.new }
  let(:uuid) { SecureRandom.uuid }

  describe "#perform" do
    context "when conversion successful" do
      it "calls CreatePDFAttachment" do
        expect(CreatePDFAttachment).to receive(:call).with(uuid)
        perform
      end
    end

    context "when conversion encounters an error" do
      before do
        allow(CreatePDFAttachment).to receive(:call).and_raise(StandardError, "Oops, something went wrong error")
      end

      context "when below warning retry count" do
        before do
          allow(instance).to receive(:retry_count).and_return(2)
        end

        it "raises an ignoreable error" do
          expect { perform }.to raise_error(described_class::SentryIgnoreThisSidekiqFailError, "Attempt to convert file (attachment_id: #{uuid}) to PDF failed on retry 2 with error \"Oops, something went wrong error\"")
        end
      end

      context "when at warning retry count" do
        before do
          allow(instance).to receive(:retry_count).and_return(3)
        end

        it "raises the erorr encountered" do
          expect { perform }.to raise_error(StandardError, "Oops, something went wrong error")
        end
      end

      context "when above warning retry count but below retry limit" do
        before do
          allow(instance).to receive(:retry_count).and_return(4)
        end

        it "raises an ignoreable error" do
          expect { perform }.to raise_error(described_class::SentryIgnoreThisSidekiqFailError, "Attempt to convert file (attachment_id: #{uuid}) to PDF failed on retry 4 with error \"Oops, something went wrong error\"")
        end
      end

      context "when at retry limit" do
        before do
          allow(instance).to receive(:retry_count).and_return(5)
        end

        it "raises an ignoreable error" do
          expect { perform }.to raise_error(described_class::SentryIgnoreThisSidekiqFailError, "Attempt to convert file (attachment_id: #{uuid}) to PDF failed on retry 5 with error \"Oops, something went wrong error\"")
        end
      end
    end
  end

  describe ".sidekiq_retries_exhausted block" do
    subject(:call_sidekiq_retries_exhausted_block) { described_class.sidekiq_retries_exhausted_block.call(msg) }

    let(:msg) { { "class" => described_class.name, "args" => [], "error_message" => "Oops, this is the last straw" } }

    let(:expected_error) do
      <<~MESSAGE
        Attachment id:  failed
        Moving PDFConverterWorker to dead set, it failed with: /Oops, this is the last straw
      MESSAGE
    end

    it "passes the error to Sentry" do
      allow(Sentry).to receive(:capture_message)
      call_sidekiq_retries_exhausted_block
      expect(Sentry).to have_received(:capture_message).with(expected_error)
    end
  end
end
