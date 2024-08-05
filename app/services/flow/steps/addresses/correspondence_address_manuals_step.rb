module Flow
  module Steps
    module Addresses
      CorrespondenceAddressManualsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_manual_path(application) },
        forward: :correspondence_address_care_ofs,
        check_answers: :check_provider_answers,
      )
    end
  end
end
