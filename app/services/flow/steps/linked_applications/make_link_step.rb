module Flow
  module Steps
    module LinkedApplications
      MakeLinkStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_make_link_path(application) },
        forward: lambda do |application|
          if application.lead_linked_application&.persisted?
            :link_application_find_link_applications
          else
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        carry_on_sub_flow: ->(application) { application&.lead_linked_application.present? || false },
        check_answers: :check_provider_answers,
      )
    end
  end
end
