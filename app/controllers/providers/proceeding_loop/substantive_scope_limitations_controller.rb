module Providers
  module ProceedingLoop
    class SubstantiveScopeLimitationsController < ProviderBaseController
      before_action :proceeding

      def show
        form
      end

      def update
        return continue_or_draft if draft_selected?
        return go_forward if form.save(form_params)

        render :show
      end

    private

      def form
        @form ||= Proceedings::ScopeLimitationsForm.call(scopes, model: proceeding)
      end

      def proceeding
        @proceeding ||= Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def form_params
        merge_with_model(proceeding) do
          params.require(:proceeding).merge({ scope_type: :substantive })
        end
      end

      def scopes
        @scopes ||= JSON.parse(LegalFramework::ProceedingTypes::Scopes.call(proceeding, false))["level_of_service"]["scope_limitations"]
      end

      def draft_selected?
        params.key?(:draft_button)
      end
    end
  end
end
