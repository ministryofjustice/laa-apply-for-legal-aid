module Providers
  module DWP
    class FallbackForm < OverridesForm
      form_for Partner

    private

      def error_scope
        if model.is_a?(Partner) && model.persisted?
          "providers.dwp.fallback.show.error.with_partner"
        else
          "providers.dwp.fallback.show.error.without_partner"
        end
      end
    end
  end
end
