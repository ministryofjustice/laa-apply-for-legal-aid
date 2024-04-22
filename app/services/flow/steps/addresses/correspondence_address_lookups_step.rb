module Flow
  module Steps
    module Addresses
      CorrespondenceAddressLookupsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_lookup_path(application) },
        forward: :correspondence_address_selections,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: true,
      )
    end
  end
end
