module Flow
  class BaseFlowService
    class << self
      attr_reader :steps

      def use_steps(steps)
        @steps = steps
      end

      def flow_service_for(journey_type, **)
        klass = case journey_type
                when :citizens
                  Flow::CitizenFlowService
                when :providers
                  Flow::ProviderFlowService
                end

        klass.new(**)
      end
    end

    attr_reader :legal_aid_application, :current_step, :params

    def initialize(legal_aid_application:, current_step:, params: nil)
      @legal_aid_application = legal_aid_application
      @current_step = current_step
      @params = params
    end

    def forward_path
      if legal_aid_application.checking_answers? && check_answers_step
        return path(forward_step) if carry_on_sub_flow?

        return path(check_answers_step)
      end

      path(forward_step)
    end

    def current_path
      path(current_step)
    end

  private

    def carry_on_sub_flow?
      carry_on_sub_flow = steps.dig(current_step, :carry_on_sub_flow)
      return false unless carry_on_sub_flow

      return carry_on_sub_flow unless carry_on_sub_flow.is_a?(Proc)

      if carry_on_sub_flow.arity == -2
        carry_on_sub_flow.call(legal_aid_application, params)
      else
        carry_on_sub_flow.call(legal_aid_application)
      end
    end

    def path(step)
      path_for(step, :path)
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
      path_for(current_step, direction)
    end

    def path_for(step, option)
      path_action = steps.dig(step, option)
      unless path_action
        raise FlowError,
              ":#{option} of step :#{step} is not defined (laa_id: #{@legal_aid_application.id}, current_step: #{@current_step}, params: #{@params.inspect}"
      end

      return path_action unless path_action.is_a?(Proc)

      if path_action.arity == 2
        path_action.call(legal_aid_application, params)
      else
        path_action.call(legal_aid_application)
      end
    end

    def steps
      self.class.steps
    end
  end
end
