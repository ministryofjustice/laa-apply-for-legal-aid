module Flow
  module Steps
    module Addresses
      NonUkHomeAddressesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_home_address_non_uk_home_address_path(application) },
        forward: lambda do |application|
          if Setting.linked_applications?
            :link_application_make_links
          else
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
