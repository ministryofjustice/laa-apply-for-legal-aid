module Flow
  module Steps
    module ProceedingsSCA
      HeardTogethersStep = Step.new(
        path: ->(application, proceeding) { Steps.urls.providers_legal_aid_application_heard_together_path(application, proceeding) },
        forward: lambda do |_application, options|
          return :proceedings_sca_heard_as_alternatives if options[:heard_together] == false

          case options[:proceeding].ccms_code
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
