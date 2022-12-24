module Providers
  class MeansReportsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show
      html = render_to_string(means_report, layout: "pdf")
      pdf = Grover.new(html).to_pdf
      send_data pdf, filename: "means_report.pdf", type: "application/pdf", disposition: "inline"
    end

  private

    def means_report
      Reports::Means.new(
        legal_aid_application: @legal_aid_application,
        manual_review_determiner:,
      )
    end

    def manual_review_determiner
      CCMS::ManualReviewDeterminer.new(@legal_aid_application)
    end
  end
end
