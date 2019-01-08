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

    "#{content_for(:page_title)} - #{default}".html_safe
  end

  def controller_t(lazy_t, *args)
    controller = controller_path.split('/')
    t ".#{[*controller, lazy_t].join('.')}", *args
  end

  def back_link(path: back_path, method: nil)
    link_to t('generic.back'), path, class: 'govuk-back-link', id: 'back', method: method
  end

  def user_header_link
#    return unless respond_to?(:provider_signed_in?) && provider_signed_in?
    html = ''
    html << link_to('John Doe', '#', class: 'user-link govuk-header__link')
    html << link_to('Sign out', '#', class: 'log-out govuk-header__link')
    html = sanitize html, tags: %w(a), attributes: %w(href class)
    content_tag :span, html, class: 'user-info'
  end
end
