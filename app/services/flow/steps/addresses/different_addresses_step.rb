module Flow
  module Steps
    module Addresses
      DifferentAddressesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_different_address_path(application) },
        forward: lambda do |application|
          if application.applicant.same_correspondence_and_home_address?
            if Setting.linked_applications?
              :link_application_make_links
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          else
            :different_address_reasons
          end
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: ->(application) { !application.applicant.same_correspondence_and_home_address? },
      )
    end
  end
end
