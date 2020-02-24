module CFE
  class BaseResult < ApplicationRecord # rubocop:disable Metrics/ClassLength
    belongs_to :legal_aid_application
    belongs_to :submission

    self.table_name = 'cfe_results'

    def overview
      if legal_aid_application.has_restrictions? && !eligible?
        'manual_check_required'
      else
        assessment_result
      end
    end
  end
end
