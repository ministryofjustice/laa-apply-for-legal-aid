module Citizens
  class CitizenBaseController < FlowBaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!
    before_action :check_not_complete
    before_action :set_cache_buster

    private

    class << self
      attr_reader :view_when_complete

      def allow_view_when_complete
        @view_when_complete = true
      end
    end

    def check_not_complete
      return if self.class.view_when_complete

      completed if legal_aid_application&.completed_at?
    end

    def completed
      redirect_to error_path(:assessment_already_completed)
    end
  end
end
