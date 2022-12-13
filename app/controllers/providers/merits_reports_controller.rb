module Providers
  class MeritsReportsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show
      html = render_to_string "show", layout: "pdf"
      pdf = Grover.new(html).to_pdf

      send_data pdf, filename: "merits_report.pdf", type: "application/pdf", disposition: "inline"
    end
  end
end
