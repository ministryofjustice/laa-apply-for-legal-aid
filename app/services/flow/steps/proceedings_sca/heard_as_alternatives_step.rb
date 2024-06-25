module Flow
  module Steps
    module ProceedingsSCA
      HeardAsAlternativesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_heard_as_alternatives_path(application) },
        forward: lambda do |_application, proceeding|
          case proceeding.ccms_code
          when "PB019", "PB020", "PB023", "PB024"
            :proceedings_sca_change_of_names
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
