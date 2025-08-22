module Providers
  class InvalidSchedulesController < ProviderBaseController
    legal_aid_application_not_required!
  end
end
