module Providers
  module Steppable
    extend ActiveSupport::Concern

    CHECK_YOUR_ANSWERS_STEP = :check_provider_answers

    PATHS_NOT_REQUIRING_LEGAL_AID_APPLICATION_INSTANCE = [
      :providers_legal_aid_applications_path
    ].freeze

    CONTROLLERS_THAT_GO_FORWARD_NORMALLY_DURING_REVIEW = [:address_lookups].freeze

    included do
      # Define @back_step_url in controller to over-ride behaviour
      def back_step_url
        raise "back step not found for controller name #{controller_name}" unless back_controller || @back_step_url

        @back_step_url ||= url_for_controller(back_controller, legal_aid_application)
      end
      helper_method :back_step_url

      def next_step_url
        raise "forward step not found for controller name #{controller_name}" unless next_controller

        url_for_controller next_controller, legal_aid_application
      end

      def url_for_application(legal_aid_application)
        name = legal_aid_application.provider_step.present? ? legal_aid_application.provider_step : :proceedings_types
        url_for_controller(name, legal_aid_application)
      end
      helper_method :url_for_application

      def url_for_controller(name, legal_aid_application)
        path = STEPS.dig(name.to_sym, :path)
        raise "Path not found for #{name}" unless path

        return public_send(path) if PATHS_NOT_REQUIRING_LEGAL_AID_APPLICATION_INSTANCE.include?(path)

        public_send path, legal_aid_application
      end

      private

      def next_controller
        return CHECK_YOUR_ANSWERS_STEP if !ignore_checking_answers? && checking_answers?

        @next_controller ||= controller_for_direction(:forward)
      end

      def back_controller
        return CHECK_YOUR_ANSWERS_STEP if checking_answers?

        @back_controller ||= controller_for_direction(:back)
      end

      def checking_answers?
        return unless @legal_aid_application

        legal_aid_application.checking_answers?
      end

      def ignore_checking_answers?
        CONTROLLERS_THAT_GO_FORWARD_NORMALLY_DURING_REVIEW.include? controller_name.to_sym
      end

      def controller_for_direction(direction)
        STEPS.dig controller_name.to_sym, direction
      end
    end
  end
end
