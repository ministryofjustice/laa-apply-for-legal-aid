module HMRC
  class Response < ApplicationRecord
    self.table_name = 'hmrc_responses'

    USE_CASES = %w[one two].freeze
    belongs_to :legal_aid_application, inverse_of: :hmrc_responses
    validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }
  end
end
