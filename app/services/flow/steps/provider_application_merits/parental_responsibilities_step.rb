module Flow
  module Steps
    module ProviderApplicationMerits
      ParentalResponsibilitiesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_has_parental_responsibility_path(application) },
        forward: lambda do |application, options|
          return :application_merits_task_check_who_client_is if options[:reshow_check_client].eql?(true)

          Flow::MeritsLoop.forward_flow(application, :application)
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
