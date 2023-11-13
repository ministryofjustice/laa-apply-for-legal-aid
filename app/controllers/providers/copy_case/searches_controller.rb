module Providers
  module CopyCase
    class SearchesController < ProviderBaseController
      prefix_step_with :copy_case

      def show
        @form = ::CopyCase::SearchForm.new(model: legal_aid_application)
      end

      def update
        @form = ::CopyCase::SearchForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:search_ref)
        end
      end
    end
  end
end
