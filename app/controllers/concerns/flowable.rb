module Flowable
  extend ActiveSupport::Concern

  included do
    def go_forward
      redirect_to forward_path
    rescue NoMethodError
      render plain: flow_service.forward_path
    end

    def back_path
      send flow_service.back_path
    end
    helper_method :back_path

    def forward_path
      send flow_service.forward_path
    end

    def flow_service
      @flow_service ||= PageFlowService.new(legal_aid_application, current_step)
    end

    def current_step
      controller_name.to_sym
    end
  end
end
