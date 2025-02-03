module ProceedingMeritsTask
  class ChancesOfSuccess < ApplicationRecord
    belongs_to :proceeding

    PRETTY_SUCCESS_PROSPECTS = {
      likely: "Likely",
      marginal: "Marginal",
      poor: "Poor",
      borderline: "Borderline",
      not_known: "Uncertain",
    }.freeze

    SUCCESS_RANKING = {
      likely: 5,
      marginal: 4,
      poor: 3,
      borderline: 2,
      not_known: 1,
    }.freeze

    enum :success_prospect, {
      likely: "likely".freeze,
      marginal: "marginal".freeze,
      poor: "poor".freeze,
      borderline: "borderline".freeze,
      not_known: "not_known".freeze,
    }, prefix: true

    def pretty_success_prospect
      PRETTY_SUCCESS_PROSPECTS[success_prospect.to_sym]
    end

    def prospect_of_success_rank
      return 1 if success_prospect.nil? # return not known if chances of success record  not yet populated

      SUCCESS_RANKING[success_prospect.to_sym]
    end

    def self.rank_and_prettify(rank)
      PRETTY_SUCCESS_PROSPECTS[SUCCESS_RANKING.invert[rank]]
    end
  end
end
