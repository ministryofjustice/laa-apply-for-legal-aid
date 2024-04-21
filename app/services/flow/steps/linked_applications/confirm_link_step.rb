module Flow
  module Steps
    module LinkedApplications
      ConfirmLinkStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_confirm_link_path(application) },
        forward: lambda do |application|
          if application.link_case.nil?
            :link_application_make_links
          else
            # TODO: This will change when ap-4827 is complete
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
