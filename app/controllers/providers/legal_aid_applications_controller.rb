module Providers
  class LegalAidApplicationsController < ProviderBaseController
    include Pagy::Backend
    legal_aid_application_not_required!

    DEFAULT_PAGE_SIZE = 20

    def index
      applications
    end

    def search
      if search_term.present?
        applications
      elsif search_term == ''
        @error = t('.error')
      end
    end

    def create
      redirect_to Flow::KeyPoint.path_for(
        journey: :providers,
        key_point: :journey_start
      )
    end

    private

    def applications
      @pagy, @legal_aid_applications = pagy(
        applications_query,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1] # control of how many elements shown in page info
      )
      @initial_sort = { created_at: :desc }
    end

    def applications_query
      query = current_provider.firm.legal_aid_applications.includes(:applicant, :merits_assessment).latest
      return query if search_term.blank?

      query.search(search_term)
    end

    def search_term
      @search_term ||= params[:search_term]
    end
  end
end
