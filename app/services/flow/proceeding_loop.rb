module Flow
  class ProceedingLoop
    LOOP_CONTROLLERS = %w[client_involvement_type delegated_functions confirm_delegated_functions_date].freeze

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
        when "delegated_functions", "in_scope_of_laspos", "has_other_proceedings", "confirm_delegated_functions_date"
          :client_involvement_type
        when "client_involvement_type"
          :delegated_functions
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
      LOOP_CONTROLLERS.include?(@application.provider_step)
    end

    def date_confirmation_required
      return false if @application.provider_step == "confirm_delegated_functions_date"

      @date_confirmation_required ||= current_proceeding&.used_delegated_functions_on&.present? && current_proceeding.used_delegated_functions_on < 1.month.ago
    end
    alias_method :date_confirmation_required?, :date_confirmation_required

    def at_end_of_loop?
      final_proceeding_in_loop.id == @application.provider_step_params["id"] && %w[delegated_functions confirm_delegated_functions_date].include?(@application.provider_step)
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
