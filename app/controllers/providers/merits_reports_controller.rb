module Providers
  class MeritsReportsController < ProviderBaseController
    include GroverOptionable

    authorize_with_policy_method :show_submitted_application?

    def show
      if params.key?(:debug)
        render "show", layout: "pdf"
      else
        html = render_to_string "show", layout: "pdf"
        pdf = Grover.new(html, style_tag_options:).to_pdf
        send_data pdf, filename: "merits_report.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end
end
