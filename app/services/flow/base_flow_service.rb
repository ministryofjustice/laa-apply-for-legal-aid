module Flow
  class BaseFlowService
    class << self
      attr_reader :steps
      def use_steps(steps)
        @steps = steps
      end

      def flow_service_for(flow_module)
        case flow_module
        when :citizens
          Flow::CitizenFlowService
        when :providers
          Flow::ProviderFlowService
        end
      end
    end

    attr_reader :legal_aid_application, :current_step

    def initialize(legal_aid_application:, current_step:)
      @legal_aid_application = legal_aid_application
      @current_step = current_step
    end

    def forward_path
      if checking_answers? && check_answers_step
        return path(forward_step) if carry_on_sub_flow?

        return path(check_answers_step)
      end

      path(forward_step)
    end

    def current_path
      path(current_step)
    end

    private

    def checking_answers?
      legal_aid_application.checking_answers? || legal_aid_application.checking_citizen_answers? || legal_aid_application.checking_passported_answers? ||
        legal_aid_application.checking_merits_answers?
    end

    def carry_on_sub_flow?
      carry_on_sub_flow = steps.dig(current_step, :carry_on_sub_flow)
      return false unless carry_on_sub_flow

      return carry_on_sub_flow unless carry_on_sub_flow.is_a?(Proc)

      carry_on_sub_flow.call(legal_aid_application)
    end

    def path(step)
      path = steps.dig(step, :path)
      raise ":path of step :#{step} is not defined" unless path

      return path unless path.is_a?(Proc)

      path.call(legal_aid_application, urls)
    end

    def forward_step
      @forward_step ||= step(:forward)
    end

    def check_answers_step
      return nil unless step?(:check_answers)

      @check_answers_step ||= step(:check_answers)
    end

    def step?(direction)
      true if steps.dig(current_step, direction)
    end

    def step(direction)
      step = steps.dig(current_step, direction)
      raise "#{direction.to_s.humanize} step of #{current_step} is not defined" unless step

      return step unless step.is_a?(Proc)

      step.call(legal_aid_application)
    end

    def steps
      self.class.steps
    end

    def urls
      @urls ||= Rails.application.routes.url_helpers
    end
  end
end
