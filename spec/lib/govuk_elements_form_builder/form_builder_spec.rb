require 'rails_helper'

class TestHelper < ActionView::Base; end

RSpec.describe GovukElementsFormBuilder::FormBuilder do
  let(:helper) { TestHelper.new }
  let(:resource)  { Applicants::BasicDetailsForm.new }
  let(:builder) { described_class.new :person, resource, helper, {} }

  it 'surrounds the field in a div' do
    output = builder.govuk_text_field(:email)

    expect(output).to start_with('<div class="govuk-form-group">')
    expect(output).to end_with('</div>')
  end

  it 'includes a label' do
    output = builder.govuk_text_field(:email)

    expect(output).to include('<label class="govuk-label" for="email">Email address</label>')
  end

  it 'adds custom class to input when passed class: "custom-class"' do
    output = builder.govuk_text_field(:email, class: 'custom-class')
    expect(output).to include('<input class="govuk-input custom-class"')
  end

  it 'includes a hint message' do
    output = builder.govuk_text_field(:email)

    expect(output).to include('class="govuk-hint"')
    expect(output).to include('id="email_hint"')
  end

  it 'does not include a hint message if hide_hint? is true' do
    output = builder.govuk_text_field(:email, hide_hint?: true)

    expect(output).not_to include('class="govuk-hint"')
  end

  context 'has an input_prefix option' do
    let(:prefix) { '£' }

    it 'includes a prefix ' do
      output = builder.govuk_text_field(:email, input_prefix: prefix)

      expected_output = [
        '<div class="govuk-prefix-input">',
        '<div class="govuk-prefix-input__inner">',
        '<span class="govuk-prefix-input__inner__unit">',
        prefix
      ].join

      expect(output).to include(expected_output)
    end
  end

  context 'when validation error on object' do
    before { resource.valid? }

    it 'includes an error message' do
      output = builder.govuk_text_field(:email)
      expect(output).to include('<span class="govuk-error-message">Enter email address</span>')
    end
  end
end
