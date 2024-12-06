module Flow
  module Steps
    module Provider
      module ProceedingInterrupts
        PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_PLF_REGEXP = /^PBM(16|17|20|21)[AE]?$/

        RelatedOrdersStep = Step.new(
          path: lambda do |application, proceeding|
            Steps.urls.providers_legal_aid_application_related_order_path(application, proceeding)
          end,
          forward: lambda do |_application, options|
            proceeding = options.is_a?(Proceeding) ? options : options[:proceeding]
            if PROHIBITED_STEPS_OR_SPECIFIC_ISSUE_PLF_REGEXP.match?(proceeding.ccms_code)
              :change_of_names
            else
              :has_other_proceedings
            end
          end,
        )
      end
    end
  end
end
