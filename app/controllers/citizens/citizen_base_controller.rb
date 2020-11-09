module Citizens
  class CitizenBaseController < FlowBaseController
    include ApplicationFromSession
    before_action :authenticate_with_devise
    before_action :check_not_complete
    before_action :set_cache_buster
    around_action :switch_locale

    private

    def authenticate_with_devise
      authenticate_applicant!
    end

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
      update_locale
      redirect_to error_path(:assessment_already_completed, default_url_options)
    end

    def switch_locale(&action)
      locale = params[:locale] || I18n.default_locale
      I18n.with_locale(locale, &action)
    end
  end
end
