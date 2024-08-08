module Flow
  module Steps
    module Addresses
      CorrespondenceAddressSelectionsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_selection_path(application) },
        forward: :correspondence_address_care_ofs,
        check_answers: :check_provider_answers,
      )
    end
  end
end
