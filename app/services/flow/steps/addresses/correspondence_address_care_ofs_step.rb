module Flow
  module Steps
    module Addresses
      CorrespondenceAddressCareOfsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_care_of_path(application) },
        forward: :home_address_statuses,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: lambda do |application|
          application.applicant.no_fixed_residence.nil? && !application.applicant.correspondence_address_choice.eql?("home")
        end,
      )
    end
  end
end
