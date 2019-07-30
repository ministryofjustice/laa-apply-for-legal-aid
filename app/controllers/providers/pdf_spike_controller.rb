module Providers
  class PdfSpikeController < ProviderBaseController
    def index
      authorize @legal_aid_application
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'PDF Spike',
                 layout: 'pdf',
                 show_as_html: params.key?(:debug)
        end
      end
    end
  end
end
