module LocaleSwitchable
  extend ActiveSupport::Concern
  include JourneyTypeIdentifiable

  included do
    helper_method :journey_type, :update_locale

    def journey_type
      return :citizens if %r{/citizens/}.match?(originating_page)

      :unknown
    end

    def originating_page
      JSON.parse(PageHistoryService.new(page_history_id: page_history_id).read)[-2]
    end

    def update_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
  end
end
