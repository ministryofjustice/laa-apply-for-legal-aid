module Flow
  module Steps
    module Addresses
      HomeAddressLookupsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_lookup_path(application) },
        forward: :home_address_selections,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: true,
      )
    end
  end
end
