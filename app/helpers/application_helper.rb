module ApplicationHelper
  def home_link
    link_url = '#'
    link_url = providers_legal_aid_applications_url if request.path_info.include?('providers')
    link_to(t('layouts.application.header.title'),
            link_url,
            class: 'govuk-header__link govuk-header__link--service-name')
  end

  def html_title
    default = t('shared.page-title.suffix')
    return default unless content_for?(:page_title)

    "#{content_for(:page_title)} - #{default}"
  end

  # Lazy translation paths are relative to the file location. So for a partial
  # at `app/views/citizens/my_controller/_form.html.erb` `<%= t('.foo') %>` will
  # render the text at:
  #
  #   en:
  #     citizens:
  #       my_controller:
  #         form:
  #           foo: 'Some text'
  #
  # Even when the partial is hosted within `app/views/providers/my_controller/show.html.erb`
  #
  # With `action_t` the path is relative to the current controller action. That is,
  # if the partial is rendered within `app/views/providers/my_controller/show.html.erb`
  # by the `Providers::MyController#show` action # `<%= action_t('.foo') %>` will render
  # the text at:
  #
  #   en:
  #     providers:
  #       my_controller:
  #         show:
  #           foo: 'Some different text'
  #
  def action_t(lazy_t)
    controller = controller_path.split('/')
    t [*controller, action_name, lazy_t].join('.')
  end
end
