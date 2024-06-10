module Providers
  module ProceedingsSCA
    class InterruptsController < ProviderBaseController
      def show
        type
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
        "default"
      end
    end
  end
end
