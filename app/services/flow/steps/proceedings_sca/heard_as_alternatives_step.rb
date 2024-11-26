module Flow
  module Steps
    module ProceedingsSCA
      HeardAsAlternativesStep = Step.new(
        path: lambda do |application, options|
          proceeding = options.is_a?(Proceeding) ? options : options[:proceeding]
          Steps.urls.providers_legal_aid_application_heard_as_alternative_path(application, proceeding)
        end,
        forward: lambda do |_application, proceeding|
          case proceeding.ccms_code
          when "PB019", "PB020", "PB023", "PB024"
            :change_of_names
          else
            :has_other_proceedings
          end
        end,
      )
    end
  end
end
