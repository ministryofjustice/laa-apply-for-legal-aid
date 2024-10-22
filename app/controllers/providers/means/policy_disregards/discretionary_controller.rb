module Providers
  module Means
    module PolicyDisregards
      class DiscretionaryController < ProviderBaseController
        def show
          @form = Providers::PolicyDisregards::DiscretionaryForm.new(model: legal_aid_application)
        end
      end
    end
  end
end
