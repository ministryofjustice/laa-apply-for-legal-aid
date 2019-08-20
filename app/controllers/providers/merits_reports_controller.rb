module Providers
  class MeritsReportsController < ProviderBaseController
    authorize_with_policy :show_submitted_application?

    def show
      render pdf: 'Merit report',
             layout: 'pdf',
             show_as_html: params.key?(:debug)
    end
  end
end
