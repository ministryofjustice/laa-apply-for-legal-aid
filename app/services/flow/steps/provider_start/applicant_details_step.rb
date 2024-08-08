module Flow
  module Steps
    module ProviderStart
      ApplicantDetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_applicant_details_path(application) },
        forward: lambda do |application|
          if application.overriding_dwp_result?
            :has_national_insurance_numbers
          else
            :correspondence_address_choices
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
