module GovukFormHelpers
  def govuk_fill_in_date_field(locator = ".govuk-form-group", text:, date: 21.years.ago)
    within(locator, text:) do
      fill_in "Day", with: date.day
      fill_in "Month", with: date.month
      fill_in "Year", with: date.year
    end
  end

  def govuk_choose(locator, **)
    choose(locator, **, visible: :all)
  end

  def expect_govuk_error_summary(text: nil)
    summary = page.find("div.govuk-error-summary > div[role='alert']")

    expect(summary).to have_css(
      "h2",
      class: "govuk-error-summary__title",
      text: "There is a problem",
    )

    expect(summary).to have_link(text)
  end

  def govuk_check(locator, **)
    check(locator, **, visible: :hidden)
  end
end
