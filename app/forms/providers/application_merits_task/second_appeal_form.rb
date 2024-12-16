module Providers
  module ApplicationMeritsTask
    class SecondAppealForm < BaseForm
      form_for ::ApplicationMeritsTask::Appeal

      attr_accessor :second_appeal

      validates :second_appeal, presence: true, unless: :draft?

      set_callback :save, :before, :sync_second_appeal_details

    private

      def sync_second_appeal_details
        if second_appeal_changed?
          attributes["original_judge_level"] = nil
          attributes["court_type"] = nil
        end
      end

      def second_appeal_changed?
        attributes["second_appeal"] != model.second_appeal.to_s
      end
    end
  end
end
