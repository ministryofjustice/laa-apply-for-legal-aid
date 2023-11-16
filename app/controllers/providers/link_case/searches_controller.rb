module Providers
  module LinkCase
    class SearchesController < ProviderBaseController
      prefix_step_with :link_case

      def show
        destroy_linked_application
        @form = ::LinkCase::SearchForm.new(model: linked_application)
      end

      def update
        @form = ::LinkCase::SearchForm.new(form_params.merge(model: linked_application, legal_aid_application:))

        render :show unless save_continue_or_draft(@form)
      end

    private

      def destroy_linked_application
        existing_linked_application.destroy! if existing_linked_application
      end

      def existing_linked_application
        LinkedApplication.find_by(associated_application_id: legal_aid_application.id)
      end

      def form_params
        params.require(:linked_application).permit(:search_ref)
      end

      def linked_application
        @linked_application ||= LinkedApplication.new
      end
    end
  end
end
