require "rails_helper"

RSpec.describe Providers::ConfirmClientDeclaration::Information, type: :component do
  subject(:component) { described_class.new(legal_aid_application:) }

  let(:legal_aid_application) do
    build_stubbed(
      :legal_aid_application,
      :with_applicant,
      applicant:,
      provider:,
    )
  end

  let(:applicant) do
    build_stubbed(:applicant, first_name: "Test", last_name: "Applicant")
  end

  let(:provider) do
    build_stubbed(:provider, firm: build_stubbed(:firm, name: "Testing Firm"))
  end

  before do
    allow(legal_aid_application)
      .to receive(:non_means_tested?)
      .and_return(non_means_tested?)

    render_inline(component)
  end

  context "when the legal aid application is means tested" do
    let(:non_means_tested?) { false }

    it "renders the means tested intro" do
      expect(page).to have_content("Test Applicant agrees that:")
    end

    it "renders only the means tested bullet points", :aggregate_failures do
      expected_bullet_points = [
        "they've instructed Testing Firm to represent them",
        "they've read the LAA privacy policy",
        "we can share their information with other government departments like " \
        "DWP and HMRC",
        "we can check their details with bank and credit reference agencies",
        "they may have to pay towards legal aid",
        "they may have to repay the legal costs if they keep or gain property " \
        "or money at the end of the case (the 'statutory charge')",
        "the information they've given is complete and correct",
        "they'll report any changes to their financial situation immediately",
      ]

      expected_bullet_points.each do |bullet|
        expect(page).to have_bullet_point(bullet)
      end

      expect(page).to have_link("LAA privacy policy")
      expect(page).not_to have_bullet_point("they are under 18")
    end

    it "renders the means tested warning", :aggregate_failures do
      expect(page).to have_warning_text(
        "If they give wrong or incomplete information, do not report " \
        "changes, or are found to have committed benefit fraud, they may:",
      )

      expected_bullet_points = [
        "be prosecuted",
        "need to pay a financial penalty",
        "have their legal aid stopped and have to pay back the costs",
      ]

      expected_bullet_points.each do |bullet|
        expect(page).to have_warning_bullet_point(bullet)
      end
    end
  end

  context "when the legal aid application is not means tested" do
    let(:non_means_tested?) { true }

    it "renders the non-means tested intro" do
      expect(page).to have_content("You agree for Test Applicant that:")
    end

    it "renders the non-means tested bullet points", :aggregate_failures do
      expected_bullet_points = [
        "they are under 18",
        "they've instructed Testing Firm to represent them",
        "they've read the LAA privacy policy",
        "we can share their information with other government departments like " \
        "DWP and HMRC",
        "we can check their details with bank and credit reference agencies",
        "they may have to pay towards legal aid",
        "they may have to repay the legal costs if they keep or gain property " \
        "or money at the end of the case (the 'statutory charge')",
        "if the case continues after their 18th birthday, we may reassess " \
        "their income and capital to check if they should contribute towards " \
        "legal costs",
        "the information they've given is complete and correct",
        "they'll report any changes to their financial situation immediately",
      ]

      expected_bullet_points.each do |bullet|
        expect(page).to have_bullet_point(bullet)
      end

      expect(page).to have_link("LAA privacy policy")
    end

    it "renders the non-means tested warning" do
      expect(page).to have_warning_text(
        "If you have given wrong or incomplete information, or do not report " \
        "changes for Test Applicant, they may:",
      )

      expected_bullet_points = [
        "be prosecuted",
        "need to pay a financial penalty",
        "have their legal aid stopped and have to pay back the costs",
      ]

      expected_bullet_points.each do |bullet|
        expect(page).to have_warning_bullet_point(bullet)
      end
    end
  end

  def have_bullet_point(text)
    have_css("ul.govuk-list--bullet > li", text:)
  end

  def have_warning_text(text)
    have_css(".govuk-warning-text", text:)
  end

  def have_warning_bullet_point(text)
    have_css(".govuk-warning-text__text > ul.govuk-list--bullet > li", text:)
  end
end
