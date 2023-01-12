module Providers
  module ConfirmClientDeclaration
    class Information < ViewComponent::Base
      def initialize(legal_aid_application:)
        @legal_aid_application = legal_aid_application
        super
      end

    private

      attr_reader :legal_aid_application

      delegate :applicant_full_name, to: :legal_aid_application

      def provider_firm_name
        legal_aid_application.provider.firm_name
      end

      def t(key, **options)
        key = ".#{i18n_prefix}.#{key}"
        super(key, **options)
      end

      def i18n_prefix
        if legal_aid_application.non_means_tested?
          :non_means_tested
        else
          :means_tested
        end
      end
    end
  end
end
