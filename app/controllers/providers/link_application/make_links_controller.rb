module Providers
  module LinkApplication
    class MakeLinksController < ProviderBaseController
      def show
        @form = Providers::LinkApplications::MakeLinkForm.new(model: legal_aid_application)
      end
    end
  end
end
