module Flow
  class ProceedingLoop
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

      if application_before_loop? || application_inside_proceeding_loop?
        :delegated_functions # TODO: This may update to the CIT page when it gets added as the next step of the mini loop
      else
        :limitations
      end
    end

    def next_proceeding
      proceeding = next_incomplete_proceeding
      proceeding = @application.proceedings.in_order_of_addition.first if next_incomplete_proceeding.nil?
      proceeding
    end

  private

    def application_before_loop?
      @application.provider_step != "delegated_functions"
    end

    def application_inside_proceeding_loop?
      @application.provider_step == "delegated_functions" && !at_end_of_loop?(@application.provider_step_params["id"])
    end

    def at_end_of_loop?(proceeding_id)
      final_proceeding_in_loop.id == proceeding_id
    end

    def final_proceeding_in_loop
      @application.proceedings.in_order_of_addition.last
    end

    def next_incomplete_proceeding
      @next_incomplete_proceeding ||= @application.proceedings.in_order_of_addition.incomplete.first
    end
  end
end
