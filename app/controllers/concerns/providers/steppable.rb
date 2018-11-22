module Providers
  module Steppable
    extend ActiveSupport::Concern

    included do
      # Keys are controller names (as returned by `controller_name.to_sym`)
      PATH_METHODS = {
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

      def back_step_url
        raise "back step not found for controller name #{controller_name}" unless current_next_method
        send current_next_method, legal_aid_application
      end
      helper_method :back_step_url

      def next_step_url
        raise "forward step not found for controller name #{controller_name}" unless current_next_method
        send current_next_method, legal_aid_application
      end

      private
      def current_next_method
        @current_next_method ||= PATH_METHODS.dig controller_name.to_sym, :forward
      end

      def current_back_method
        @current_back_method ||= PATH_METHODS.dig controller_name.to_sym, :back
      end
    end
  end
end
