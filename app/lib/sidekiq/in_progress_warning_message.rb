module Sidekiq
  class InProgressWarningMessage
    def initialize(source, hmrc_response, retry_count)
      @source = source.to_s
      @hmrc_response = hmrc_response
      @retry_count = retry_count
    end

    def self.call(source, hmrc_response, retry_count)
      new(source, hmrc_response, retry_count).call
    end

    def call
      <<~ERROR
        #{call_type}: #{@hmrc_response.id} is failing, retry count at #{@retry_count}
      ERROR
    end

  private

    def call_type
      {
        'HMRC::SubmissionWorker' => 'HMRC submission id',
        'HMRC::ResultWorker' => 'HMRC result check for id',
      }[@source]
    end
  end
end
