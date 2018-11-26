module Providers
  module Steppable
    extend ActiveSupport::Concern

    # Keys are controller names (as returned by `controller_name.to_sym`)
    STEPS = {
      legal_aid_applications: {
        forward: :new_providers_legal_aid_application_applicant_path,
        back: :providers_root_path
      },
      applicants: {
        forward: :new_providers_legal_aid_application_address_lookups_path,
        back: :new_providers_legal_aid_application_path
      },
      address_lookups: {
        # Forward determined by controller action logic
        back: :new_providers_legal_aid_application_applicant_path
      },
      address_selections: {
        forward: :providers_legal_aid_application_check_benefits_path,
        back: :new_providers_legal_aid_application_applicant_path
      },
      addresses: {
        forward: :providers_legal_aid_application_check_benefits_path,
        back: :new_providers_legal_aid_application_applicant_path
      },
      check_benefits: {
        forward: :providers_legal_aid_application_email_path,
        back: :new_providers_legal_aid_application_address_lookups_path
      },
      emails: {
        forward: :providers_legal_aid_application_check_your_answers_path,
        back: :providers_legal_aid_application_check_benefits_path
      },
      check_your_answers: {
        forward: :providers_legal_aid_applications_path,
        back: :providers_legal_aid_application_email_path
      }
    }.freeze

    included do
      def back_step_url
        raise "back step not found for controller name #{controller_name}" unless current_back_method
        send current_back_method, with_legal_aid_application_if_needed(current_back_method)
      end
      helper_method :back_step_url

      def next_step_url
        raise "forward step not found for controller name #{controller_name}" unless current_next_method
        send current_next_method, with_legal_aid_application_if_needed(current_next_method)
      end

      private

      def current_next_method
        @current_next_method ||= STEPS.dig controller_name.to_sym, :forward
      end

      def current_back_method
        @current_back_method ||= STEPS.dig controller_name.to_sym, :back
      end

      def with_legal_aid_application_if_needed(current_method)
        return if paths_not_requiring_legal_aid_application_instance.include?(current_method)
        legal_aid_application
      end

      def paths_not_requiring_legal_aid_application_instance
        %i[providers_legal_aid_applications_path providers_root_path]
      end
    end
  end
end
