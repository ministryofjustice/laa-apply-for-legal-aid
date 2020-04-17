module Providers
  class MeansReportsController < ProviderBaseController
    authorize_with_policy :show_submitted_application?

    def show
      @cfe_result = @legal_aid_application.cfe_result
      render pdf: 'Means report',
             layout: 'pdf',
             show_as_html: params.key?(:debug)
    end
  end
end
