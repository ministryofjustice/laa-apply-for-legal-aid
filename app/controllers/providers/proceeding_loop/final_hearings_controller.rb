module Providers
  module ProceedingLoop
    class FinalHearingsController < ProviderBaseController
      before_action :proceeding

      def show
        @form = Proceedings::FinalHearingForm.new(model: final_hearing)
      end

      def update
        @form = Proceedings::FinalHearingForm.new(form_params.merge(work_type:))
        render :show unless save_continue_or_draft(@form, work_type:)
      end

    private

      def work_type_param
        params.require(:work_type)
      end

      def work_type
        @work_type ||= work_type_param.to_sym == :substantive ? :substantive : :emergency
      end

      def proceeding
        @proceeding = Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def final_hearing
        @final_hearing ||= proceeding.final_hearings.send(work_type).first || proceeding.final_hearings.build(work_type:)
      end

      def form_params
        merged_params = merge_with_model(final_hearing) do
          params.expect(final_hearing: [:listed, :date, :details])
        end
        convert_date_params(merged_params)
      end
    end
  end
end
