module HMRC
  class ResponseValidator < ActiveModel::Validator
    VALID_STATUSES = %w[completed processing].freeze

    attr_reader :record

    def validate(record)
      @record = record
      return if record.response.nil?

      validate_response
    end

  private

    def validate_response
      validate_response_submission
      validate_response_status
      validate_response_data
    end

    def validate_response_submission
      record.errors.add(:response, "response \"submission\" must be present") if record.response["submission"].blank?
    end

    def validate_response_status
      record.errors.add(:response, "response \"status\" must be one of allowed options") unless VALID_STATUSES.include?(record.response["status"])
    end

    def validate_response_data
      data = record.response&.fetch("data", nil)
      return if data.nil? || data.is_a?(Array)

      record.errors.add(:response, 'response "data" must be an array')
    end
  end
end
