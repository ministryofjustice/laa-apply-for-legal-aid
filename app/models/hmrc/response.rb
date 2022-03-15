module HMRC
  class Response < ApplicationRecord
    self.table_name = 'hmrc_responses'

    after_create :persist_parsed_response

    USE_CASES = %w[one two].freeze
    belongs_to :legal_aid_application, inverse_of: :hmrc_responses
    validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }

    def self.use_case_one_for(laa_id)
      where(legal_aid_application_id: laa_id, use_case: 'one').order(:created_at).last
    end

    def employment_income?
      return false if response.nil?

      data_array = response&.dig('data')
      paye_hash = data_array&.detect { |hash| hash.key?('income/paye/paye') }
      income_array = paye_hash&.dig('income/paye/paye', 'income')

      return false if income_array.nil?

      !income_array.empty?
    end

  private

    def persist_parsed_response
      HMRC::ParsedResponse::Persistor.call(legal_aid_application)
    end
  end
end
