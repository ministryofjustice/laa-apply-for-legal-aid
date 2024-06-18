module Flow
  module Steps
    module Partner
      DetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_details_path(application) },
        forward: lambda do |application|
          if application.overriding_dwp_result?
            :check_client_details
          else
            :check_provider_answers
          end
        end,
        check_answers: :check_provider_answers,
        carry_on_sub_flow: false,
      )
    end
  end
end
