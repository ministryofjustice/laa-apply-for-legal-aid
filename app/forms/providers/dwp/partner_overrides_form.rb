module Providers
  module DWP
    class PartnerOverridesForm < OverridesForm
      form_for Partner

    private

      def error_scope
        "providers.dwp.partner_overrides.show.error"
      end
    end
  end
end
