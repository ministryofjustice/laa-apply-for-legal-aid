module HMRC
  class Response < ApplicationRecord
    self.table_name = 'hmrc_responses'

    USE_CASES = %w[one two].freeze
    belongs_to :legal_aid_application, inverse_of: :hmrc_responses
    validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }

    def self.use_case_one_for(laa_id)
      where(legal_aid_application_id: laa_id, use_case: 'one').order(:created_at).last
    end
  end
end
