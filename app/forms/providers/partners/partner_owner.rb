module Providers
  module Partners
    module PartnerOwner
      def owner
        legal_aid_application&.partner
      end
    end
  end
end
