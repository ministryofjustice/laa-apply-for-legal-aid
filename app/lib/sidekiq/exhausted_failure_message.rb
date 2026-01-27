module Sidekiq
  class ExhaustedFailureMessage
    def initialize(msg)
      @msg = msg
    end

    def self.call(msg)
      new(msg).call
    end

    def call
      <<~ERROR
        #{call_type}: #{@msg['args'].first} failed
        Moving #{@msg['class']} to dead set, it failed with: #{@msg['error_class']}/#{@msg['error_message']}
      ERROR
    end

  private

    def call_type
      {
        "HMRC::SubmissionWorker" => "HMRC submission id",
        "HMRC::ResultWorker" => "HMRC result check for id",
        "CCMS::SubmissionProcessWorker" => "CCMS submission id",
        "PDFConverterWorker" => "Attachment id",
      }[@msg["class"]]
    end
  end
end
