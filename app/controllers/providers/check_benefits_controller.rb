module Providers
  class CheckBenefitsController < BaseController
    include ApplicationDependable
    include Flowable

    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?
    end

    def update
      go_forward
    end
  end
end
