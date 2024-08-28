module Flow
  class ProceedingLoop
    LOOP_CONTROLLERS = %w[client_involvement_type
                          delegated_functions
                          confirm_delegated_functions_date
                          emergency_defaults
                          emergency_level_of_service
                          emergency_scope_limitations
                          substantive_defaults
                          substantive_level_of_service
                          substantive_scope_limitations].freeze

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
      return :confirm_delegated_functions_date if date_confirmation_required
      return :delegated_functions if provider_needs_to_amend_date?
      return :limitations if at_end_of_loop?

      if application_before_loop? || application_inside_proceeding_loop? || date_confirmation_required?
        case @application.provider_step
        when "has_other_proceedings"
          if @application.checking_answers? && next_incomplete_proceeding.nil?
            :limitations
          else
            :client_involvement_type
          end
        when "substantive_scope_limitations"
          if @application.checking_answers?
            :limitations
          else
            :client_involvement_type
          end
        when "client_involvement_type"
          :delegated_functions
        when "delegated_functions", "confirm_delegated_functions_date"
          current_proceeding.used_delegated_functions? && !current_proceeding.special_childrens_act? ? :emergency_defaults : :substantive_defaults
        when "emergency_defaults"
          current_proceeding.accepted_emergency_defaults ? :substantive_defaults : :emergency_level_of_service
        when "substantive_defaults"
          if current_proceeding.accepted_substantive_defaults
            if @application.checking_answers? && next_incomplete_proceeding.nil?
              :limitations
            else
              :client_involvement_type
            end
          else
            :substantive_level_of_service
          end
        when "emergency_level_of_service"
          :emergency_scope_limitations
        when "substantive_level_of_service"
          :substantive_scope_limitations
        when "emergency_scope_limitations"
          :substantive_defaults
        end
      end
    end

    def next_proceeding
      proceeding = next_incomplete_proceeding
      if next_incomplete_proceeding.nil?
        proceeding = if at_final_page_for_proceeding? && current_proceeding_id.present?
                       @application.proceedings.in_order_of_addition[current_proceeding_position + 1]
                     else
                       @application.proceedings.in_order_of_addition.first
                     end
      end
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
      @controllers ||= LOOP_CONTROLLERS
    end

    def date_confirmation_required
      return false if @application.provider_step != "delegated_functions"

      @date_confirmation_required ||= current_proceeding&.used_delegated_functions_on.present? && current_proceeding.used_delegated_functions_on < 1.month.ago
    end
    alias_method :date_confirmation_required?, :date_confirmation_required

    def at_end_of_loop?
      final_proceeding_in_loop.id == @application.provider_step_params["id"] && at_final_page_for_proceeding?
    end

    def at_final_page_for_proceeding?
      # this checks if the current provider step is in the last two values in controllers
      # this is because confirm_delegated_functions_date is optional so
      # delegated_functions or confirm_delegated_functions_date could both be the final page
      controllers[-3..].include?(@application.provider_step)
    end

    def final_proceeding_in_loop
      @application.proceedings.in_order_of_addition.last
    end

    def next_incomplete_proceeding
      @next_incomplete_proceeding ||= Query::IncompleteProceedings.call(@application)&.in_order_of_addition&.first
    end

    def current_proceeding_id
      @current_proceeding_id ||= @application.provider_step_params.present? && @application.provider_step_params["id"] ? @application.provider_step_params["id"] : nil
    end

    def current_proceeding_position
      @current_proceeding_position ||= @application.proceedings.in_order_of_addition.pluck(:id).index current_proceeding_id
    end

    def current_proceeding
      return nil if current_proceeding_id.nil?

      @current_proceeding ||= @application.proceedings.find(current_proceeding_id)
    end
  end
end
