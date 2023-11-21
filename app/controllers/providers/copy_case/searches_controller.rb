module Providers
  module CopyCase
    class SearchesController < ProviderBaseController
      prefix_step_with :copy_case

      before_action :set_search_ref, only: :show

      def show
        @form = ::CopyCase::SearchForm.new(model: legal_aid_application)
      end

      def update
        @form = ::CopyCase::SearchForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def set_search_ref
        @search_ref = searched_for_case&.application_ref
      end

      def searched_for_case
        @searched_for_case ||= LegalAidApplication.find_by(id: legal_aid_application&.copy_case_id)
      end

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:search_ref)
        end
      end
    end
  end
end
