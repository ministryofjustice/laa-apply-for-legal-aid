module Providers
  module ApplicationMeritsTask
    class OriginalJudgeLevelForm < BaseForm
      form_for ::ApplicationMeritsTask::Appeal

      attr_accessor :original_judge_level

      JUDGE_LEVELS = %w[
        family_panel_magistrates
        deputy_district_judge
        district_judge
        recorder_circuit_judge
        high_court_judge
      ].freeze

      validates :original_judge_level, presence: true, inclusion: { in: JUDGE_LEVELS }, unless: :draft?

      def judge_levels
        JUDGE_LEVELS
      end
    end
  end
end
