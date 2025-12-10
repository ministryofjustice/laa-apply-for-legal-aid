module Flow
  module Steps
    module Addresses
      CorrespondenceAddressChoicesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_correspondence_address_choice_path(application) },
        forward: lambda do |application|
          correspondence_address_choice = application.applicant.correspondence_address_choice if application
          {
            home: :home_address_lookups,
            residence: :correspondence_address_lookups,
            office: :correspondence_address_manuals,
          }[correspondence_address_choice.to_sym]
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: lambda do |_application, options = {}|
          options.fetch(:correspondence_address_choice_changed, true)
        end,
      )
    end
  end
end
