module Providers
  class MeritsReportsController < ProviderBaseController
    def show
      render pdf: 'Merit report',
             layout: 'pdf',
             show_as_html: params.key?(:debug)
    end
  end
end
