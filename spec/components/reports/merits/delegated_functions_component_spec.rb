require "rails_helper"

RSpec.describe Reports::Merits::DelegatedFunctionsComponent, type: :component do
  subject(:component) { described_class.new(proceeding:) }

  before { render_inline(component) }

  context "when delegated functions were used in the proceeding" do
    let(:proceeding) do
      build_stubbed(
        :proceeding,
        :with_df_date,
        meaning: "Test proceeding meaning",
        used_delegated_functions_on: Date.new(2025, 1, 1),
        used_delegated_functions_reported_on: Date.new(2025, 1, 8),
      )
    end

    it "renders the proceeding heading" do
      expect(page).to have_css("h2", text: "Test proceeding meaning")
    end

    it "renders the delegated functions summary list", :aggregate_failures do
      expect(page).to have_summary_list_row(
        key: "Date reported",
        value: "8 January 2025",
      )
      expect(page).to have_summary_list_row(
        key: "Date delegated functions were used",
        value: "1 January 2025",
      )
      expect(page).to have_summary_list_row(
        key: "Days to report",
        value: "7 days",
      )
    end

    it "does not render the no delegated functions used message" do
      expect(page).to have_no_css("p", text: "Not used")
    end
  end

  context "when delegated functions were not used in the proceeding" do
    let(:proceeding) do
      build_stubbed(
        :proceeding,
        :without_df_date,
        meaning: "Test proceeding meaning",
      )
    end

    it "renders the proceeding heading" do
      expect(page).to have_css("h3", text: "Test proceeding meaning")
    end

    it "renders the no delegated functions used message" do
      expect(page).to have_css("p", text: "Not used")
    end

    it "does not render the delegated functions summary list" do
      expect(page).to have_no_css("dl.govuk-summary-list")
    end
  end

  def have_summary_list_row(key:, value:)
    SummaryListRow.new(key, value)
  end
end
