module ProvidersHelper
  # A wrapper for the main elements needed in a Providers page.
  # On a simple page, this will wrap the main content:
  #
  #   <%= provider_basic_page(page_title: 'Some Page') do %>
  #     <p>Some content</p>
  #   <% end %>
  #
  # On more complex pages, the method can be called without a block to create
  # an initial `govuk-grid-row` containing just the main page heading.
  #
  #   <%= provider_basic_page(page_title: 'Some Page') %>
  #
  # If the page contains a form, you can use the :form template that will put
  # the content within a fieldset and the heading into a fieldset heading:
  #
  #   <%= provider_basic_page(page_title: 'Some Page', template: :form) do %>
  #     <%= form_with(model: @form) do |form| %>
  #       ...
  #     <% end %>
  #   <% end %>
  #
  def provider_basic_page( # rubocop:disable Metrics/ParameterLists
        page_title:,
        back_link: {},
        column_width: 'two-thirds',
        template: nil,
        show_errors_for: @form,
        &content
      )
    content = capture(&content) if content
    template = :default unless %i(form basic).include?(template)
    content_for(:navigation) { provider_back_link(back_link) unless back_link == :none }
    content_for(:page_title) { page_title }
    render(
      "shared/providers/#{template}_page_template",
      page_title: page_title,
      back_link: back_link,
      column_width: column_width,
      content: content,
      show_errors_for: show_errors_for
    )
  end

  def provider_back_link(text: t('generic.back'), path: back_step_url, method: :get)
    link_to text, path, class: 'govuk-back-link', id: 'back-top', method: method
  end
end
