module TaskList
  class StartPageCollection < Collection
    NEW_RECORD = "00000000-0000-0000-0000-000000000000".freeze

    # Template:
    #
    # SECTIONS = {
    #   task_list_section: {
    #     body_override ->(application) { "my section message content" if application.my_condition? },
    #     task_list_item_1 (name after step): displayed?,
    #     task_list_item_2 (name after step): displayed?,
    #     ....
    #     subsections: {
    #       subsection_name: {
    #         body_override ->(application) { "my subsection message content" if application.my_condition? },
    #         sub_task_list_item_1 (name after step): displayed?
    #      }
    #    }
    #   }
    # }
    #
    # Rules: name task list items after the [first] step in its flow.
    #
    # e.g.
    #  - Steps::ProviderStart::ApplicantsStep --> applicants
    #  - Steps::ProviderStart::AboutFinancialMeansStep --> about_financial_means
    #
    # Body override:
    #
    # If the section's task list cannot be shown and requires text to be displayed instead then the
    # body_override task key should be added. It's lambda should return the message to be displayed
    # only if it needs to be displayed. This will override displaying of the tasks for that section
    # replacing the tasks with the message body provided.
    #
    # e.g. body_override: ->(application) { "Not available yet because..." unless application.client_and_case_details_completed? },
    #

    SECTIONS = {
      client_and_case_details: {
        applicants: true, # Steps::ProviderStart::ApplicantsStep
        make_link: true, # Steps::ProviderStart::MakeLinkStep
        check_provider_answers: true, # Steps::ProviderStart::CheckProviderAnswersStep
        dwp_outcome: true, # Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep
      },
      means_assessment: {
        body_override: ->(application) { t!("task_list.body_override.means.requirement_unknown") if application.journey_unknown? || application.non_means_tested? },
        subsections: {
          financial_information: {
            body_override: ->(application) { t!("task_list.body_override.means.financial_information_not_needed") if application.passported? },
          },
          capital_and_assets: {},
        },
      },
      merits_assessment: {
        body_override: ->(application) { t!("task_list.body_override.merits.requirement_unknown") if application.proceedings.blank? },
        subsections: {
          about_this_application: {},
          about_the_proceedings: {},
          supporting_evidence_and_review: {},
        },
      },
      confirm_and_submit: {},
    }.freeze
  end
end
