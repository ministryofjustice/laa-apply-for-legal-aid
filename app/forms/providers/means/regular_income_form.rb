module Providers
  module Means
    class RegularIncomeForm < BaseRegularIncomeForm
      include ApplicantOwner
    end
  end
end
