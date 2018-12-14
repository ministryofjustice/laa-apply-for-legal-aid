module Providers
  module Steppable
    extend ActiveSupport::Concern

    # Keys are controller names (as returned by `controller_name.to_sym`)
    STEPS = {
      legal_aid_applications: {
        forward: :providers_legal_aid_application_proceedings_type_path
        # No back: start of journey
      },
      proceedings_types: {
        forward: :providers_legal_aid_application_applicant_path,
        back: :providers_legal_aid_applications_path
      },
      applicants: {
        forward: :providers_legal_aid_application_address_lookup_path,
        back: :providers_legal_aid_application_proceedings_type_path
      },
      address_lookups: {
        forward: :providers_legal_aid_application_address_selection_path,
        back: :providers_legal_aid_application_applicant_path
      },
      address_selections: {
        forward: :providers_legal_aid_application_check_provider_answers_path,
        back: :providers_legal_aid_application_address_lookup_path
      },
      addresses: {
        forward: :providers_legal_aid_application_check_provider_answers_path,
        back: :providers_legal_aid_application_address_lookup_path
      },
      check_benefits: {
        # forward: :providers_legal_aid_application_check_provider_answers_path,
        back: :providers_legal_aid_application_check_provider_answers_path
      },
      check_provider_answers: {
        forward: :providers_legal_aid_application_check_benefits_path,
        # Back determined by controller action logic
      },
      online_bankings: {
        forward: :providers_legal_aid_application_about_the_financial_assessment_path,
        back: :providers_legal_aid_application_check_benefits_path
      },
      about_the_financial_assessments: {
        back: :providers_legal_aid_application_online_banking_path
      }
    }.freeze

    PATHS_NOT_REQUIRING_LEGAL_AID_APPLICATION_INSTANCE = [
      :providers_legal_aid_applications_path
    ].freeze

    CHECK_YOUR_ANSWERS_STEP = :providers_legal_aid_application_check_provider_answers_path

    CONTROLLERS_THAT_GO_FORWARD_NORMALLY_DURING_REVIEW = [:address_lookups].freeze

    included do
      # Define @back_step_url in controller to over-ride behaviour
      def back_step_url
        raise "back step not found for controller name #{controller_name}" unless current_back_method || @back_step_url

        @back_step_url ||= send(current_back_method, with_legal_aid_application_if_needed(current_back_method))
      end
      helper_method :back_step_url

      def next_step_url
        raise "forward step not found for controller name #{controller_name}" unless current_next_method

        send current_next_method, with_legal_aid_application_if_needed(current_next_method)
      end

      private

      def current_next_method
        return CHECK_YOUR_ANSWERS_STEP if !ignore_checking_answers? && checking_answers?

        @current_next_method ||= STEPS.dig controller_name.to_sym, :forward
      end

      def current_back_method
        return CHECK_YOUR_ANSWERS_STEP if checking_answers?

        @current_back_method ||= STEPS.dig controller_name.to_sym, :back
      end

      def with_legal_aid_application_if_needed(current_method)
        return if PATHS_NOT_REQUIRING_LEGAL_AID_APPLICATION_INSTANCE.include?(current_method)

        legal_aid_application
      end

      def checking_answers?
        return unless @legal_aid_application

        legal_aid_application.checking_answers?
      end

      def ignore_checking_answers?
        CONTROLLERS_THAT_GO_FORWARD_NORMALLY_DURING_REVIEW.include? controller_name.to_sym
      end
    end
  end
end
