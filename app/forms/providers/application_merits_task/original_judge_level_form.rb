module Providers
  module ApplicationMeritsTask
    class OriginalJudgeLevelForm < BaseForm
      form_for ::ApplicationMeritsTask::Appeal

      attr_accessor :original_judge_level

      set_callback :save, :before, :sync_court_type

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

    private

      def sync_court_type
        if original_judge_level_changed?
          attributes["court_type"] = nil
        end
      end

      def original_judge_level_changed?
        attributes["original_judge_level"] != model.original_judge_level
      end
    end
  end
end
