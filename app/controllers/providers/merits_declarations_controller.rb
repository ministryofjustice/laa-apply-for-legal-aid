module Providers
  class MeritsDeclarationsController < BaseController
    include ApplicationDependable
    include Steppable

    before_action :authorize_legal_aid_application

    def show; end

    def update
      merits_assessment.update!(client_merits_declaration: true)
      redirect_to next_step_url
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
