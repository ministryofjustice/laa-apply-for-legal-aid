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
end
