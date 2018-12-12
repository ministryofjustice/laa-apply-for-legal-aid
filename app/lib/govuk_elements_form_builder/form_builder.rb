module GovukElementsFormBuilder
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Prevents surrounding of erroneous inputs with <div class="field_with_errors">
    # https://guides.rubyonrails.org/configuring.html#configuring-action-view
    ActionView::Base.field_error_proc = proc { |html_tag| html_tag.html_safe }

    delegate :content_tag, to: :@template
    delegate :errors, to: :@object

    def govuk_text_field(attribute, *args)
      content_tag :div, class: form_group_classes(attribute) do
        options = args.extract_options!

        label_classes!(options)
        field_classes!(options, attribute)

        form_group(options, attribute)
      end
    end

    private

    def form_group(options, attribute)
      html = label(attribute, options[:label_options].merge(for: attribute))

      html.concat(hint_tag(attribute)) if !options[:hide_hint?] && hint_message(attribute)
      html.concat(error_tag(attribute)) if error?(attribute)

      html.concat(field_tag(options, attribute))

      html.html_safe
    end

    def field_tag(options, attribute)
      input_prefix = options.delete(:input_prefix)
      tag = text_field(attribute, options.except(:label, :label_options).merge(id: attribute))
      return tag unless input_prefix

      input_prefix_group(input_prefix) { tag }
    end

    def input_prefix_group(input_prefix)
      content_tag :div, class: 'govuk-prefix-input' do
        content_tag :div, class: 'govuk-prefix-input__inner' do
          html = content_tag :span, input_prefix, class: 'govuk-prefix-input__inner__unit'
          html.concat(yield)
          html
        end
      end
    end

    # Given an attributes hash that could include any number of arbitrary keys, this method
    # ensure we merge one or more 'default' attributes into the hash, creating the keys if
    # don't exist, or merging the defaults if the keys already exists.
    # It supports strings or arrays as values.
    #
    def merge_attributes(attributes, default:)
      hash = attributes || {}
      hash.merge!(default) { |_key, oldval, newval| [newval] + [oldval] }
    end

    def field_classes!(options, attribute)
      default_classes = ['govuk-input']
      default_classes << 'govuk-input--error' if error?(options[:field_with_error] || attribute)
      default_classes << 'govuk-prefix-input__inner__input' if options[:input_prefix]

      options ||= {}
      merge_attributes(options, default: { class: default_classes })
    end

    def label_classes!(options)
      options ||= {}
      options[:label_options] ||= {}
      merge_attributes(options[:label_options], default: { class: 'govuk-label' })
    end

    def hint_message(attribute)
      I18n.translate("helpers.hint.#{attribute}", default: nil)
    end

    def hint_tag(attribute)
      message = hint_message(attribute)
      return unless message

      content_tag(:span, message, class: 'govuk-hint', id: "#{attribute}_hint")
    end

    def error_tag(attribute)
      return unless error?(attribute)

      content_tag(:span, object.errors[attribute].join(', '), class: 'govuk-error-message')
    end

    def error?(attribute)
      object.respond_to?(:errors) &&
        errors.messages.key?(attribute) &&
        errors.messages[attribute].present?
    end

    def form_group_classes(attribute)
      classes = 'govuk-form-group'
      classes += ' govuk-form-group--error' if error?(attribute)
      classes
    end
  end
end
