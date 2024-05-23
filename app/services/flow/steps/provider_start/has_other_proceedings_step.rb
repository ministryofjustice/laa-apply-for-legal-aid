module Flow
  module Steps
    module ProviderStart
      HasOtherProceedingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_has_other_proceedings_path(application) },
        forward: lambda do |application, add_another_proceeding|
          if add_another_proceeding
            :proceedings_types
          else
            Flow::ProceedingLoop.next_step(application)
          end
        end,
      )
    end
  end
end
