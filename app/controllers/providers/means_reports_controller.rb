module Providers
  class MeansReportsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show
      @cfe_result = @legal_aid_application.cfe_result
      @manual_review_determiner = CCMS::ManualReviewDeterminer.new(@legal_aid_application)

      html = render_to_string "show", layout: "pdf"
      pdf = Grover.new(html).to_pdf

      send_data pdf, filename: "means_report.pdf", type: "application/pdf", disposition: "inline"
    end
  end
end
