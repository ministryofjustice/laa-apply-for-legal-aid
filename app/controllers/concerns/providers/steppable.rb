module Providers
  module Steppable
    extend ActiveSupport::Concern

    STEPS = [
      { step: :proceedings, action: :new_proceeding },
      { step: :basic_details, action: :new_client_detail },
      { step: :address, action: :new_providers_applicant_address_lookups_path, args: [:applicant] },
      { step: :email, action: :edit_providers_legal_aid_application_applicant_path, args: [:application] },
      { step: :submission_completed, action: :providers_legal_aid_application_check_your_answers_path, args: [:application] }
    ].freeze

    included do
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
end
