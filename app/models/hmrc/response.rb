module HMRC
  class Response < ApplicationRecord
    self.table_name = "hmrc_responses"

    after_update :persist_employment_records, unless: :submission_started?

    USE_CASES = %w[one two].freeze
    belongs_to :legal_aid_application, inverse_of: :hmrc_responses
    validates :use_case, presence: true, inclusion: { in: USE_CASES }

    def self.use_case_one_for(laa_id)
      where(legal_aid_application_id: laa_id, use_case: "one").order(:created_at).last
    end

    def status
      return nil if response.blank?

      response["status"]
    end

    def employment_income?
      return false if response.nil?

      data_array = response&.dig("data")
      paye_hash = data_array&.detect { |hash| hash.key?("income/paye/paye") }
      income_array = paye_hash&.dig("income/paye/paye", "income")

      return false if income_array.nil?

      !income_array.empty?
    end

  private

    def persist_employment_records
      return unless saved_changes?

      HMRC::ParsedResponse::Persistor.call(self)
    end

    def submission_started?
      saved_change_to_url? && saved_change_to_submission_id?
    end
  end
end
