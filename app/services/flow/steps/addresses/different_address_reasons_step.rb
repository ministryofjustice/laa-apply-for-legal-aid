module Flow
  module Steps
    module Addresses
      DifferentAddressReasonsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_different_address_reason_path(application) },
        forward: lambda do |application|
          if application.applicant.no_fixed_residence?
            if Setting.linked_applications?
              :link_application_make_links
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          else
            :home_address_lookups
          end
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: ->(application) { !application.applicant.no_fixed_residence? },
      )
    end
  end
end
