require 'rails_helper'

RSpec.describe GovukElementsFormBuilder::FormBuilder do
  let(:view_context) { ActionController::Base.new.view_context }
  let(:resource) { 'applicant' }
  let(:resource_form) { Applicants::BasicDetailsForm.new }
  let(:builder) { described_class.new resource.to_sym, resource_form, view_context, {} }
  let(:parsed_html) { Nokogiri::HTML(subject) }

  shared_examples_for 'a basic input field' do
    it 'surrounds the field in a div' do
      div = tag.parent
      expect(div.name).to eq('div')
      expect(div.classes).to include('govuk-form-group')
    end

    it 'includes a label' do
      expect(label.classes).to include('govuk-label')
      expect(label[:for]).to eq(attribute)
      expect(label.content).to eq(label_copy)
    end

    it 'includes a hint message' do
      hint_span = tag.parent.at_css("span##{attribute}-hint")
      expect(hint_span.classes).to include('govuk-hint')
      expect(hint_span.content).to include(hint_copy)
      expect(tag['aria-describedby']).to eq("#{attribute}-hint")
    end

    context 'hint: nil' do
      let(:params) { [attribute.to_sym, { hint: nil }] }

      it 'does not include a hint message' do
        expect(subject).not_to include('govuk-hint')
        expect(tag['aria-describedby']).to eq(nil)
      end
    end

    context 'Display hint and no label (label: nil, hint: hint_copy)' do
      let(:params) { [attribute.to_sym, { label: nil, hint: hint_copy }] }

      it 'does not include a hint message' do
        expect(subject).not_to include('govuk-label')
        expect(subject).to include('govuk-hint')
      end
    end

    context 'pass a label parameter' do
      let(:custom_label) { Faker::Lorem.sentence }
      let(:params) { [attribute.to_sym, { label: custom_label }] }

      it 'shows the custom label' do
        expect(label.classes).to include('govuk-label')
        expect(label[:for]).to eq(attribute)
        expect(label.content).to eq(custom_label)
      end
    end

    context 'when validation error on object' do
      let(:nino_error) { I18n.t("activemodel.errors.models.#{resource}.attributes.#{attribute}.blank") }

      before { resource_form.valid? }

      it 'includes an error message' do
        error_span = tag.previous_element
        expect(error_span.content).to include(nino_error)
        expect(error_span.name).to eq('span')
        expect(error_span.classes).to include('govuk-error-message')
        expect(tag.classes).to include(expected_error_class)
        expect(tag['aria-describedby'].split(' ')).to include('national_insurance_number-error')
        expect(tag.parent.classes).to include('govuk-form-group--error')
      end
    end

    context 'adding a custom class to the input' do
      let(:custom_class) { 'govuk-!-width-one-third' }
      let(:params) { [attribute.to_sym, { class: custom_class }] }

      it 'adds custom class to the input' do
        expect(tag.classes).to include(custom_class)
      end
    end

    context 'pass a label parameter with text and size' do
      let(:custom_label) { Faker::Lorem.sentence }
      let(:params) { [attribute.to_sym, { label: { text: custom_label, size: :m } }] }

      it 'shows the custom label' do
        expect(label.classes).to include('govuk-label')
        expect(label[:for]).to eq(attribute)
        expect(label.content).to eq(custom_label)
      end

      it 'includes a size class' do
        expect(label.classes).to include('govuk-label--m')
      end
    end
  end

  describe 'fieldset_legend' do
    subject { builder.__send__(:fieldset_legend, params) }

    context 'with just text title' do
      let(:params) { 'This is my title' }
      it 'returns the html' do
        expected_html = '<legend class="govuk-fieldset__legend govuk-fieldset__legend--xl"><h1 class="govuk-fieldset__heading">This is my title</h1></legend>'
        expect(subject).to eq expected_html
      end
    end

    context 'passing in a title hash' do
      let(:params) do
        {
          text: 'My text',
          size: :m
        }
      end
      it 'returns html with medium size' do
        expected_html = '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m"><h1 class="govuk-fieldset__heading">My text</h1></legend>'
        expect(subject).to eq expected_html
      end
    end

    context 'passing in a title hash' do
      let(:params) do
        {
          text: 'My text',
          size: :m,
          htag: :h2
        }
      end
      it 'returns html with medium size' do
        expected_html = '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m"><h2 class="govuk-fieldset__heading">My text</h2></legend>'
        expect(subject).to eq expected_html
      end
    end
  end

  describe 'govuk_text_field' do
    let(:attribute) { 'national_insurance_number' }
    let(:params) { [attribute.to_sym] }
    let(:label_copy) { I18n.t("activemodel.attributes.#{resource}.#{attribute}") }
    let(:hint_copy) { I18n.t("helpers.hint.#{resource}.#{attribute}") }
    let(:tag) { parsed_html.at_css("input##{attribute}") }
    let(:label) { tag.parent.at_css('label') }
    let(:expected_error_class) { 'govuk-input--error' }

    subject { builder.govuk_text_field(*params) }

    it_behaves_like 'a basic input field'

    it 'generates a text field' do
      expect(tag.classes).to include('govuk-input')
      expect(tag[:type]).to eq('text')
      expect(tag[:name]).to eq("#{resource}[#{attribute}]")
    end

    context 'suffix' do
      let(:params) { [attribute.to_sym, { suffix: 'litres' }] }

      it 'shows the suffix' do
        expect(subject).to include %(<span class="input-suffix"> litres</span></div>)
      end
    end

    context 'has an input_prefix option' do
      let(:prefix) { '£' }
      let(:params) { [attribute.to_sym, { input_prefix: prefix }] }

      it 'includes a prefix ' do
        expect(tag.previous_element.content).to eq(prefix)
        expect(tag.previous_element.name).to eq('span')
        expect(tag.previous_element.classes).to contain_exactly('govuk-prefix-input__inner__unit')
        expect(tag.parent.name).to eq('div')
        expect(tag.parent.classes).to contain_exactly('govuk-prefix-input__inner')
        expect(tag.parent.parent.name).to eq('div')
        expect(tag.parent.parent.classes).to contain_exactly('govuk-prefix-input')
      end
    end
  end

  describe 'govuk_text_area' do
    let(:attribute) { 'national_insurance_number' }
    let(:params) { [attribute.to_sym] }
    let(:label_copy) { I18n.t("activemodel.attributes.#{resource}.#{attribute}") }
    let(:hint_copy) { I18n.t("helpers.hint.#{resource}.#{attribute}") }
    let(:tag) { parsed_html.at_css("textarea##{attribute}") }
    let(:label) { tag.parent.at_css('label') }
    let(:expected_error_class) { 'govuk-textarea--error' }

    subject { builder.govuk_text_area(*params) }

    it_behaves_like 'a basic input field'

    it 'generates a text_area tag' do
      expect(tag.name).to eq('textarea')
      expect(tag.classes).to include('govuk-textarea')
      expect(tag[:name]).to eq("#{resource}[#{attribute}]")
    end
  end

  describe 'govuk_file_field' do
    let(:attribute) { 'national_insurance_number' }
    let(:params) { [attribute.to_sym] }
    let(:label_copy) { I18n.t("activemodel.attributes.#{resource}.#{attribute}") }
    let(:hint_copy) { I18n.t("helpers.hint.#{resource}.#{attribute}") }
    let(:label) { tag.parent.at_css('label') }
    let(:tag) { parsed_html.at_css('input[type=file]') }
    let(:expected_error_class) { 'govuk-file-upload--error' }

    subject { builder.govuk_file_field(*params) }

    it_behaves_like 'a basic input field'

    it 'generates a file_field tag' do
      expect(tag.classes).to include('govuk-file-upload')
      expect(tag[:type]).to eq('file')
      expect(tag[:name]).to eq("#{resource}[#{attribute}]")
    end
  end

  describe 'govuk_radio_button' do
    let(:attribute) { 'understands_terms_of_court_order' }
    let(:resource_form) { Respondents::RespondentForm.new }
    let(:hint_copy) { 'hint hint' }
    let(:label_copy) { CGI.escapeHTML I18n.t("helpers.label.respondent.#{attribute}.true") }
    let(:input) { parsed_html.at_css("input##{resource}_#{attribute}_true") }
    let(:value) { true }
    let(:params) { [:understands_terms_of_court_order, value, { hint: hint_copy }] }

    subject { builder.govuk_radio_button(*params) }

    it 'generates a radio button' do
      expect(input.classes).to include('govuk-radios__input')
      expect(input[:type]).to eq('radio')
      expect(input[:value]).to eq(value.to_s)
      expect(input[:name]).to eq("#{resource}[#{attribute}]")
    end

    it 'surrounds the field in a div' do
      div = input.parent

      expect(div.name).to eq('div')
      expect(div.classes).to include('govuk-radios__item')
    end

    it 'includes a label' do
      label = input.parent.at_css('label')

      expect(label.classes).to include('govuk-label')
      expect(label.classes).to include('govuk-radios__label')
      expect(label[:for]).to eq("#{resource}_#{attribute}_true")
      expect(label.content).to eq(label_copy)
    end

    it 'includes a hint message' do
      hint_span = input.parent.at_css('span.govuk-hint')
      expect(hint_span.content).to include(hint_copy)
      expect(hint_span[:id]).to eq("#{attribute}-#{value}-hint")
    end

    context 'adding a custom class to the input' do
      let(:custom_class) { 'govuk-!-width-one-third' }
      let(:params) { [:understands_terms_of_court_order, value, { class: custom_class }] }

      it 'adds custom class to the input' do
        expect(input.classes).to include(custom_class)
      end
    end

    context 'label is passed as a parameter' do
      let(:custom_label) { Faker::Lorem.sentence }
      let(:params) { [:understands_terms_of_court_order, value, { label: custom_label }] }

      it 'display the custom label instead of the one in locale file' do
        label = input.parent.at_css('label')
        expect(label.content).to eq(custom_label)
      end
    end
  end

  describe 'govuk_collection_radio_buttons' do
    let(:attribute) { 'understands_terms_of_court_order' }
    let(:resource_form) { Respondents::RespondentForm.new }
    let(:options) { [true, false] }
    let(:params) { [:understands_terms_of_court_order, options] }
    let(:inputs) { options.map { |option| parsed_html.at_css("input##{resource}_#{attribute}_#{option}") } }
    let(:input) { inputs.first }
    let(:div_radios) { parsed_html.at_css('div.govuk-radios') }
    let(:div_form_group) { parsed_html.at_css('div.govuk-form-group') }
    let(:fieldset) { parsed_html.at_css('fieldset') }
    let(:legend) { parsed_html.at_css('legend') }
    let(:h1) { parsed_html.at_css('h1') }

    subject { builder.govuk_collection_radio_buttons(*params) }

    it 'generates radio buttons' do
      expect(inputs.size).to eq(options.size)
      expect(inputs.pluck(:class).uniq).to include('govuk-radios__input')
      expect(inputs.pluck(:type).uniq).to include('radio')
      expect(inputs.pluck(:value)).to eq(options.map(&:to_s))
      expect(inputs.pluck(:name).uniq).to include("#{resource}[#{attribute}]")
    end

    it 'surrounds the radio buttons in a div' do
      expect(div_radios.children.size).to eq(options.size)
      expect(div_radios.search('[type=radio]').count).to eq(options.size)
      expect(div_radios.children.pluck(:class).uniq).to include('govuk-radios__item')
    end

    it 'surrounds everything in a from group div' do
      first_div = parsed_html.search('div').first
      expect(first_div.classes).to include('govuk-form-group')
    end

    it 'includes a fieldset tag' do
      expect(div_form_group.child.name).to eq('fieldset')
      expect(fieldset.classes).to include('govuk-fieldset')
    end

    context 'when a hint message is passed as a parameter' do
      let(:hint_message) { 'Choose an option' }
      let(:params) { [:understands_terms_of_court_order, options, { hint: hint_message }] }

      it 'the hint message appears only once' do
        expect(parsed_html.css('span.govuk-hint').count).to eq(1)
      end
    end

    context 'when an error message is passed as a parameter' do
      let(:error_message) { 'Something wrong' }
      let(:params) { [:understands_terms_of_court_order, options, { error: error_message }] }

      it 'the error message is shown' do
        expect(parsed_html.at_css('span.govuk-error-message').content).to include(error_message)
      end
    end

    context 'when there is a hint message defined' do
      let(:hint_message) { 'Choose an option' }
      let(:span_hint) { parsed_html.at_css('span.govuk-hint') }

      before do
        en = { helpers: { hint: { resource => { attribute => hint_message } } } }
        I18n.backend.store_translations(:en, en)
      end

      it 'includes a hint message' do
        expect(fieldset['aria-describedby'].split(' ')).to include("#{attribute}-hint")
        expect(span_hint[:id]).to eq("#{attribute}-hint")
        expect(span_hint.content).to eq(hint_message)
        expect(span_hint.parent).to eq(fieldset)
      end

      it 'the hint message appears only once' do
        expect(parsed_html.css('span.govuk-hint').count).to eq(1)
      end
    end

    context 'when validation error on object' do
      let(:error_message) { I18n.t("activemodel.errors.models.respondent.attributes.#{attribute}.blank") }
      let(:span_error) { parsed_html.at_css('span.govuk-error-message') }

      before { resource_form.valid? }

      it 'includes an error message' do
        expect(fieldset['aria-describedby'].split(' ')).to include("#{attribute}-error")
        expect(span_error[:id]).to eq("#{attribute}-error")
        expect(span_error.content).to include(error_message)
        expect(span_error.parent).to eq(fieldset)
      end
    end

    context 'title is passed as a parameter' do
      let(:title) { 'Pick an option' }
      let(:params) { [:understands_terms_of_court_order, options, { title: title }] }

      it 'display the title in a <legend> and <h1> tag' do
        expect(fieldset.child.name).to eq('legend')
        expect(fieldset.child.child.name).to eq('h1')
        expect(legend.classes).to include('govuk-fieldset__legend')
        expect(legend.classes).to include('govuk-fieldset__legend--xl')
        expect(h1.classes).to include('govuk-fieldset__heading')
        expect(h1.content).to eq(title)
      end
    end

    context 'title is passed as text and size' do
      let(:title) { 'Pick an option' }
      let(:params) { [:understands_terms_of_court_order, options, { title: { text: title, size: :m } }] }

      it 'display the title in a <legend> and <h1> tag' do
        expect(fieldset.child.name).to eq('legend')
        expect(fieldset.child.child.name).to eq('h1')
        expect(legend.classes).to include('govuk-fieldset__legend')
        expect(legend.classes).to include('govuk-fieldset__legend--m')
        expect(h1.classes).to include('govuk-fieldset__heading')
        expect(h1.content).to eq(title)
      end
    end

    context 'input_attributes are passed as parameters' do
      let(:input_attribute) { { 'data-aria-controls' => 'details' } }
      let(:input_attributes) { { true.to_s => input_attribute } }
      let(:params) { [:understands_terms_of_court_order, options, { input_attributes: input_attributes }] }

      it 'adds the attribute only to the right attribute' do
        correct_radio_button = parsed_html.at_css('input[value="true"]')
        other_radio_button   = parsed_html.at_css('input[value="false"]')
        correct_radio_button['data-aria-controls'] = 'details'
        expect(correct_radio_button['data-aria-controls']).to eq('details')
        expect(other_radio_button['data-aria-controls']).to eq(nil)
      end
    end
  end
end
