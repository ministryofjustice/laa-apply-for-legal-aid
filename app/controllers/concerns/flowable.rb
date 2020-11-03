module Flowable
  extend ActiveSupport::Concern
  include JourneyTypeIdentifiable

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
    helper_method :forward_path

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

    def path?(string)
      string.starts_with?('/')
    end

    def current_step
      [self.class.step_prefix, controller_name].compact.join('_').to_sym
    end
  end
end
