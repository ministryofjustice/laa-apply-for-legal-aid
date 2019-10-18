module CFE
  class Result < ApplicationRecord
    belongs_to :legal_aid_application
    belongs_to :submission

    def result_hash
      JSON.parse(result, symbolize_names: true)
    end

    def capital_contribution_required?
      assessment_result == 'contribution_required'
    end

    def assessment_result
      result_hash[:assessment_result]
    end

    def capital_contribution
      result_hash[:capital][:capital_contribution].to_d
    end
  end
end
