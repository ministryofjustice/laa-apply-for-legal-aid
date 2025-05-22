module Providers
  module ProceedingsSCA
    class InterruptsController < ProviderBaseController
      prefix_step_with :proceedings_sca
      def show
        type
      end

      def destroy
        legal_aid_application.proceedings.order(:created_at).last.destroy!
        replace_last_page_in_history(home_path)
        redirect_to providers_legal_aid_application_proceedings_types_path
      end

    private

      def type
        @type ||= type_param
      end

      def type_param
        I18n.t("title_html", scope: "providers.proceedings_sca.interrupts.show.#{params.require(:type)}").match(/^translation missing/i).present?
        params.require(:type)
      rescue ActionController::ParameterMissing, I18n::MissingTranslationData
        # TODO: Placeholder to allow fallback while developing
        "proceeding_issue_status"
      end
    end
  end
end
