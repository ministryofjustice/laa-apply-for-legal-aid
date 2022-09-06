module Flow
  class ProceedingLoop
    LOOP_CONTROLLERS = %w[client_involvement_type delegated_functions confirm_delegated_functions_date].freeze
    EXTENDED_LOOP_CONTROLLERS = %w[emergency_defaults emergency_level_of_service substantive_defaults substantive_level_of_service].freeze

    def initialize(application)
      @application = application
    end

    def self.next_step(application)
      new(application).next_step
    end

    def self.next_proceeding(application)
      new(application).next_proceeding
    end

    def next_step
      return :used_multiple_delegated_functions unless Setting.enable_mini_loop?
      return :confirm_delegated_functions_date if date_confirmation_required
      return :delegated_functions if provider_needs_to_amend_date?
      return :limitations if at_end_of_loop?

      if application_before_loop? || application_inside_proceeding_loop? || date_confirmation_required?
        case @application.provider_step
        when "in_scope_of_laspos", "has_other_proceedings", "substantive_level_of_service"
          :client_involvement_type
        when "client_involvement_type"
          :delegated_functions
        when "delegated_functions", "confirm_delegated_functions_date"
          if Setting.enable_loop?
            current_proceeding.used_delegated_functions? ? :emergency_defaults : :substantive_defaults
          else
            :client_involvement_type
          end
        when "emergency_defaults"
          current_proceeding.accepted_emergency_defaults ? :substantive_defaults : :emergency_level_of_service
        when "substantive_defaults"
          current_proceeding.accepted_substantive_defaults ? :client_involvement_type : :substantive_level_of_service
        when "emergency_level_of_service"
          :substantive_defaults
        end
      end
    end

    def next_proceeding
      proceeding = next_incomplete_proceeding
      proceeding = @application.proceedings.in_order_of_addition.first if next_incomplete_proceeding.nil?
      proceeding
    end

  private

    def provider_needs_to_amend_date?
      @application.provider_step == "confirm_delegated_functions_date" &&
        @application.provider_step_params["binary_choice_form"]["confirm_delegated_functions_date"] == "false"
    end

    def application_before_loop?
      %w[has_other_proceedings in_scope_of_laspos].include?(@application.provider_step)
    end

    def application_inside_proceeding_loop?
      controllers.include?(@application.provider_step)
    end

    def controllers
      @controllers ||= Setting.enable_loop? ? LOOP_CONTROLLERS + EXTENDED_LOOP_CONTROLLERS : LOOP_CONTROLLERS
    end

    def date_confirmation_required
      return false if @application.provider_step == "confirm_delegated_functions_date"

      @date_confirmation_required ||= current_proceeding&.used_delegated_functions_on&.present? && current_proceeding.used_delegated_functions_on < 1.month.ago
    end
    alias_method :date_confirmation_required?, :date_confirmation_required

    def at_end_of_loop?
      final_proceeding_in_loop.id == @application.provider_step_params["id"] && controllers[-2..].include?(@application.provider_step)
    end

    def final_proceeding_in_loop
      @application.proceedings.in_order_of_addition.last
    end

    def next_incomplete_proceeding
      @next_incomplete_proceeding ||= @application.proceedings.in_order_of_addition.incomplete.first
    end

    def current_proceeding
      return nil if @application.provider_step_params["id"].nil?

      @current_proceeding ||= @application.proceedings.find(@application.provider_step_params["id"])
    end
  end
end
