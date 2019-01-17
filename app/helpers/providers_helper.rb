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
  # If the page contains a form, pass the form object in, and error and fieldset
  # markup will be added to match:
  #
  #   <%= provider_basic_page(page_title: 'Some Page', form: @form) do %>
  #     <%= form_with(model: @form) do |form| %>
  #       ...
  #     <% end %>
  #   <% end %>
  #
  def provider_basic_page(page_title:, back_link: {}, column_width: 'two-thirds', form: nil, &content)
    content = capture(&content) if content
    template = form ? 'form_page_template' : 'basic_page_template'
    render(
      "shared/providers/#{template}",
      page_title: page_title,
      back_link: back_link,
      column_width: column_width,
      content: content
    )
  end

  def provider_back_link(text: t('generic.back'), path: back_step_url, method: :get)
    link_to text, path, class: 'govuk-back-link', id: 'back-top', method: method
  end
end
