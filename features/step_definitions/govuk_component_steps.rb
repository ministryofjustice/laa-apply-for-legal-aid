# frozen_string_literal: true

When("I choose govuk radio {string} for {string}") do |label, legend|
  find(".govuk-fieldset__legend", text: legend)
    .find(:xpath, "..")
    .find(".govuk-radios__item label", text: label).click
end
