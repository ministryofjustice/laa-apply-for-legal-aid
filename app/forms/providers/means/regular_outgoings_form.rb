module Providers
  module Means
    class RegularOutgoingsForm < BaseRegularOutgoingsForm
      include ApplicantOwner
    end
  end
end
