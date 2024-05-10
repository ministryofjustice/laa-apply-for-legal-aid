module Flow
  module Steps
    module LinkedApplications
      ConfirmLinkStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_confirm_link_path(application) },
        forward: lambda do |application|
          link = application&.lead_linked_application
          return :link_application_copies if link.confirm_link && link.link_type_code == "FC_LEAD"
          return :link_application_make_links if link.confirm_link.nil?

          application.proceedings.any? ? :has_other_proceedings : :proceedings_types
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: ->(application) { application.lead_linked_application&.link_type_code == "FC_LEAD" },
      )
    end
  end
end
