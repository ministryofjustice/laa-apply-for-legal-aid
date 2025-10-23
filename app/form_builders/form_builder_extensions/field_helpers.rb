module FormBuilderExtensions
  module FieldHelpers
    def moj_date_picker_field(attribute_name, options = {})
      content_tag(:div, class: "moj-datepicker", data: { module: "moj-date-picker" }) do
        govuk_text_field(
          attribute_name,
          **options,
          class: "moj-js-datepicker-input",
        )
      end
    end
  end
end
