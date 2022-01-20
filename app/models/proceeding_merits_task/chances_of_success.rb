module ProceedingMeritsTask
  class ChancesOfSuccess < ApplicationRecord
    belongs_to :proceeding

    # TODO: remove once LFA migration is complete
    after_create :populate_proceeding

    PRETTY_SUCCESS_PROSPECTS = {
      likely: 'Likely (>50%)',
      marginal: 'Marginal (45-49%)',
      poor: 'Poor (<45%)',
      borderline: 'Borderline',
      not_known: 'Uncertain'
    }.freeze

    SUCCESS_RANKING = {
      likely: 5,
      marginal: 4,
      poor: 3,
      borderline: 2,
      not_known: 1
    }.freeze

    enum success_prospect: {
      likely: 'likely'.freeze,
      marginal: 'marginal'.freeze,
      poor: 'poor'.freeze,
      borderline: 'borderline'.freeze,
      not_known: 'not_known'.freeze
    }, _prefix: true

    def self.prospects_unlikely_to_succeed
      success_prospects.except(:likely).keys
    end

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

    private

    # TODO: temp method to ensure the link is made to Proceeding until the LFA migration is complete
    # :nocov:
    def populate_proceeding
      return unless proceeding_id.nil?

      self.proceeding_id = application_proceeding_type.proceeding.id
    end
    # :nocov:
  end
end
