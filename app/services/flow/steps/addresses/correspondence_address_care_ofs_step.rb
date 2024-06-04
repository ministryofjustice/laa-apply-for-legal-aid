module Flow
  module Steps
    module Addresses
      CorrespondenceAddressCareOfsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_care_of_path(application) },
        forward: :home_address_statuses,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: true,
      )
    end
  end
end
