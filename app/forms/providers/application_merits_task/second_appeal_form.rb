module Providers
  module ApplicationMeritsTask
    class SecondAppealForm < BaseForm
      form_for ::ApplicationMeritsTask::Appeal

      attr_accessor :second_appeal

      validates :second_appeal, presence: true, unless: :draft?

      set_callback :save, :before, :sync_original_judge_level

      # Alternative callback
      # set_callback :validation, :after, :sync_original_judge_level

    private

      def sync_original_judge_level
        attributes["original_judge_level"] = nil if second_appeal?
      end

      def second_appeal?
        attributes["second_appeal"] == "true"
      end
    end
  end
end
