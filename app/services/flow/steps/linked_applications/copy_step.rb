module Flow
  module Steps
    module LinkedApplications
      CopyStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_copy_path(application) },
        forward: lambda do |application|
          if application.copy_case?
            application.non_means_tested? ? :check_provider_answers : :client_has_partners
          else
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: ->(application) { !application.copy_case? || false },
      )
    end
  end
end
