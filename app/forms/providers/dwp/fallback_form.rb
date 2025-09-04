module Providers
  module DWP
    class FallbackForm < OverridesForm
      form_for Partner

    private

      def error_scope
        "providers.dwp.fallback.show.error"
      end
    end
  end
end
