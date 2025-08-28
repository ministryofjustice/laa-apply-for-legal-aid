module Flow
  module Steps
    module Addresses
      HomeAddressManualsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_manual_path(application) },
        forward: :link_application_make_links,
        check_answers: :check_provider_answers,
      )
    end
  end
end
