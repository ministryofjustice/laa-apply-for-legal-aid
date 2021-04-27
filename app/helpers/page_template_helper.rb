module PageTemplateHelper
  # A wrapper for the main elements needed in a page.
  #
  # `page_template` will wrap the main content, and add the main elements needed
  # at the start of each page (HTML title, navigation links, and heading):
  #
  #   <%= page_template(page_title: 'Some Page') do %>
  #     <p>Some content</p>
  #   <% end %>
  #
  # On more complex pages, the method can be called without a block to create
  # an initial `govuk-grid-row` containing just the main page heading.
  #
  #   <%= page_template(page_title: 'Some Page') %>
  #
  # If the page contains a form, you can use the :form template that will put
  # the content within a fieldset and the heading into a fieldset heading:
  #
  #   <%= page_template(page_title: 'Some Page', template: :form) do %>
  #     <%= form_with(model: @form) do |form| %>
  #       ...
  #     <% end %>
  #   <% end %>
  #
  # Where a minimal wrapper is needed (for example when the heading needs
  # to be positioned within a form), use the :basic template
  #
  #   <%= page_template(page_title: 'Some Page', template: :basic) do %>
  #     <p>Some content</p>
  #   <% end %>
  #
  # If a panel is required, declare the panel before calling the template method, and
  # it will be inserted into the page (default template only):
  #
  #   <% content_for(:panel) { 'Panel content } %>
  #   <%= page_template(page_title: 'Some Page') do %>
  #     <p>Main content</p>
  #   <% end %>
  #

  def page_template( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    page_title: nil,
    head_title: nil,
    back_link: {},
    column_width: 'two-thirds',
    template: nil,
    form: nil,
    show_errors_for: nil,
    success_message: nil,
    page_heading_options: {},
    &content
  )
    template = :default unless %i[form basic].include?(template)
    content_for(:navigation) { back_link(**back_link) unless back_link == :none }
    has_errors = form&.object&.errors || show_errors_for&.errors
    page_title_possibly_with_error({ page_title: page_title, head_title: head_title }, has_errors)
    content = capture(&content) if content
    content_for(:language_switcher) { language_links if show_language_switcher? }
    render(
      "shared/page_templates/#{template}_page_template",
      page_title: page_title,
      head_title: head_title,
      back_link: back_link,
      column_width: column_width,
      content: content,
      form: form,
      show_errors_for: show_errors_for,
      success_message: success_message,
      page_heading_options: page_heading_options
    )
  end

  def page_heading(heading: :h1, size: :xl, margin_bottom: nil)
    return unless page_title

    classes = ["govuk-heading-#{size}"]
    classes << "govuk-!-margin-bottom-#{margin_bottom}" if margin_bottom
    content_tag heading, page_title, class: classes.join(' ')
  end

  def page_title
    content_for(:page_title) if content_for?(:page_title)
  end

  def page_title_possibly_with_error(page_headings, errors)
    errors.present? ? error_page_title(page_headings) : simple_page_title(page_headings)
  end

  def simple_page_title(headings)
    content_for(:page_title) { headings[:page_title] }
    content_for(:head_title) { headings[:head_title] || headings[:page_title] }
  end

  def error_page_title(headings)
    prefix = t('errors.title_prefix')
    content_for(:page_title) { headings[:page_title] }
    content_for(:head_title) { "#{prefix}: #{headings[:head_title] || headings[:page_title]}" }
  end
end
