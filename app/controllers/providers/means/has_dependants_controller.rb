module Providers
  module Means
    class HasDependantsController < ProviderBaseController
      def show
        @form = LegalAidApplications::HasDependantsForm.new(model: legal_aid_application)
      end

      def update
        @form = LegalAidApplications::HasDependantsForm.new(form_params.merge(draft: params[:draft_button].present?))
        if @form.save
          return continue_or_draft if draft_selected?

          remove_dependants unless legal_aid_application.has_dependants?
          go_forward
        else
          render :show
        end
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:has_dependants])
        end
      end

      def remove_dependants
        legal_aid_application.dependants.destroy_all
      end
    end
  end
end
