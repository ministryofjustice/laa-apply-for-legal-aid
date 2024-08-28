module Flow
  module Steps
    module Addresses
      CorrespondenceAddressManualsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_manual_path(application) },
        forward: :correspondence_address_care_ofs,
        check_answers: :correspondence_address_care_ofs,
        carry_on_sub_flow: ->(application) { application.applicant.address.care_of.nil? },
      )
    end
  end
end
