module Flow
  module Steps
    module LinkedApplications
      ConfirmLinkStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_confirm_link_path(application) },
        forward: lambda do |application|
          case application.link_case
          when true
            :link_application_copies
          when false
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          else
            :link_application_make_links
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
