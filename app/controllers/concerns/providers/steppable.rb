module Providers
  module Steppable
    STEPS = [
      { step: :proceedings, action: :new_providers_legal_aid_application_path },
      { step: :basic_details, action: :new_providers_legal_aid_application_applicant, args: [:application] },
      { step: :address, action: :new_providers_legal_aid_application_address_lookups_path, args: [:application] },
      { step: :check_benefits, action: :providers_legal_aid_application_check_benefits_path, args: [:application] },
      { step: :email, action: :providers_legal_aid_application_email_path, args: [:application] },
      { step: :submission_completed, action: :providers_legal_aid_application_check_your_answers_path, args: [:application] }
    ].freeze

    ENTRY_PATH_METHODS = {
      legal_aid_applications: :new_providers_legal_aid_application_path,
      applications:           :new_providers_legal_aid_application_applicant_path,
      addresses:              :new_providers_legal_aid_application_address_lookups_path,
      check_benefits:         :providers_legal_aid_application_check_benefits_path,
      emails:                 :providers_legal_aid_application_email_path,
      check_your_answers:     :providers_legal_aid_application_check_your_answers_path
    }.freeze

    def current_step
      @current_step || raise('@current_step needs to be set')
    end

    def action_for_next_step(step: current_step, options: {})
      index = STEPS.index { |h| h[:step] == step.to_sym }
      return :applications unless index
      next_step = STEPS[index + 1]
      return :providers_legal_aid_applications unless next_step
      path_args = (next_step[:args] || []).each_with_object([]) do |arg, array|
        array << options[arg] if options[arg].present?
      end
      send(next_step[:action], *path_args)
    end
  end
end
