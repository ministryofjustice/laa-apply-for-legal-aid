module Providers
  class ProvidersController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      puts ">>>>>>>>>>>> providers controller#show #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
      @provider = current_provider
    end
  end
end
