module Flow
  module Steps
    module LinkedApplications
      CopyStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_copy_path(application) },
        forward: lambda do |application|
          if application.copy_case?
            :has_national_insurance_numbers
          else
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
