module Providers
  class LegalAidApplicationsController < ProviderBaseController
    include Pagy::Backend

    legal_aid_application_not_required!

    before_action :set_scope, :load_announcements, only: %i[in_progress search submitted voided]

    DEFAULT_PAGE_SIZE = 20

    def index; end

    def submitted
      applications(submitted_query)
      render "index"
    end

    def in_progress
      applications(in_progress_query)
      @voided_applications = voided_query
      render "index"
    end

    def voided
      applications(voided_query)
    end

    def search
      if search_term.present?
        applications(applications_query)
        log_search
      elsif search_term == ""
        @error = t(".error")
      end
    end

    def create
      redirect_to Flow::KeyPoint.path_for(
        journey: :providers,
        key_point: :journey_start,
      )
    end

  private

    def set_scope
      @scope = params[:action].to_sym
    end

    def load_announcements
      @announcements = current_provider.announcements
    end

    def applications(query)
      @pagy, @legal_aid_applications = pagy(
        query,
        limit: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: 5, # control of how many elements shown in page info
      )
      @initial_sort = { created_at: :desc }
    end

    def applications_query
      query = firms_applications.includes(:applicant, :chances_of_success).excluding(voided_query)

      query.search(search_term)
    end

    def submitted_query
      firms_applications.completed_applications
    end

    def in_progress_query
      firms_applications.includes(:applicant, :chances_of_success)
                        .excluding(voided_query)
                        .excluding(submitted_query)
                        .latest
    end

    def voided_query
      firms_applications.voided_applications
    end

    def firms_applications
      current_provider.firm.legal_aid_applications.kept
    end

    def search_term
      @search_term ||= params[:search_term]
    end

    def log_search
      Rails.logger.info("Applications search: Provider #{current_provider.id} searched '#{search_term}' : #{@pagy.count} results.")
    end
  end
end
