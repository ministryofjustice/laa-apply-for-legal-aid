module Flow
  module Steps
    module Addresses
      NonUkHomeAddressesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_non_uk_home_address_path(application) },
        forward: :link_application_make_links,
        check_answers: :check_provider_answers,
      )
    end
  end
end
