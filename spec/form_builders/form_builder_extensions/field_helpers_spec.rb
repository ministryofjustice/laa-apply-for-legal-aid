require "rails_helper"

RSpec.describe FormBuilderExtensions::FieldHelpers do
  let(:builder) { ActionView::Base.default_form_builder.new(dummy_model.model_name, model_instance, view_context, {}) }
  let(:view_context) { ActionView::Base.new(ActionController::Base.view_paths, {}, nil) }

  let(:model_instance) { dummy_model.new(my_date_picker_attribute: Time.zone.today) }

  let(:dummy_model) do
    Class.new do
      include ActiveModel::Model # gives validations, errors, etc.

      attr_accessor :my_date_picker_attribute

      # Needed for FormBuilder to detect the model name
      def self.model_name
        "dummy_model"
      end
    end
  end

  describe "#moj_date_picker_field" do
    subject(:html) do
      builder.moj_date_picker_field(
        :my_date_picker_attribute,
        value: model_instance.my_date_picker_attribute.to_s(:date_picker),
        label: { text: "my date picker label" },
        hint: { text: "my date picker hint" },
      )
    end

    def clean_html(html)
      html
        .lines
        .map(&:squish) # remove trailing and leading whitespace and newlines
        .join # rejoin lines
    end

    let(:expected_html) do
      clean_html(<<-HTML)
        <div class="moj-datepicker" data-module="moj-date-picker">
          <div class="govuk-form-group">
            <label for="dummy-model-my-date-picker-attribute-field" class="govuk-label">my date picker label</label>
            <div class="govuk-hint" id="dummy-model-my-date-picker-attribute-hint">my date picker hint</div>
            <input id="dummy-model-my-date-picker-attribute-field" class="govuk-input moj-js-datepicker-input" aria-describedby="dummy-model-my-date-picker-attribute-hint" value="#{model_instance.my_date_picker_attribute.to_s(:date_picker)}" type="text" name="dummy_model[my_date_picker_attribute]" />
          </div>
        </div>
      HTML
    end

    it "renders the date picker field with the expected attributes" do
      expect(html).to eql(expected_html)
    end
  end
end
