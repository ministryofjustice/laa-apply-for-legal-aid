module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessForm < BaseForm
      form_for ::ProceedingMeritsTask::ChancesOfSuccess

      attr_accessor :proceeding_id, :success_likely, :success_prospect_details

      validates :success_likely, inclusion: %w[true false], unless: :draft?
      validates :success_prospect_details, presence: true, if: :requires_details?

      set_callback :save, :before, :sync_success_prospect

    private

      def sync_success_prospect
        if success_likely == "true"
          attributes["success_prospect"] = :likely
          attributes["success_prospect_details"] = nil
        elsif success_likely == "false"
          attributes["success_prospect"] = :not_known
        end
      end

      def requires_details?
        success_likely.to_s == "false" && !draft?
      end
    end
  end
end
