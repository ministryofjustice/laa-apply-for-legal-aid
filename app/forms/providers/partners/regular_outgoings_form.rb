module Providers
  module Partners
    class RegularOutgoingsForm < BaseRegularOutgoingsForm
      include PartnerOwner
    end
  end
end
