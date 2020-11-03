module Flowable
  extend ActiveSupport::Concern

  class_methods do
    # Use a step prefix to avoid step name clashes.
    # For example:
    #
    #    class BarsController < ProviderBaseController
    #      prefix_step_with :foo
    #
    # With this modification step name will be :foo_bars rather than :bars
    def prefix_step_with(prefix)
      @step_prefix = prefix
    end

    def step_prefix
      @step_prefix
    end
  end

  included do
    helper_method :forward_path, :journey_type

    def go_forward(flow_param = nil)
      path = forward_path(flow_param)

      redirect_to path if path?(path)
    end

    def forward_path(flow_param = nil)
      flow_service(flow_param).forward_path
    end

    def flow_service(flow_param = nil)
      Flow::BaseFlowService.flow_service_for(
        journey_type,
        legal_aid_application: legal_aid_application,
        current_step: current_step,
        params: flow_param
      )
    end

    def journey_type
      @journey_type ||= first_module_of_parent_name_space.to_sym
    end

    def first_module_of_parent_name_space
      parent_name_space_module.to_s.snakecase.split('/').first
    end

    def parent_name_space_module
      self.class.module_parent
    end

    def path?(string)
      string.starts_with?('/')
    end

    def current_step
      [self.class.step_prefix, controller_name].compact.join('_').to_sym
    end
  end
end
