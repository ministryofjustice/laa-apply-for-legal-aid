module LanguageSwitcherHelper
  def language_links
    links = ''

    I18n.available_locales.each do |locale|
      link = I18n.locale == locale ? t("generic.#{locale}") : link_to_accessible(t("generic.#{locale}"), url_for(locale: locale))
      links << "#{link} | "
    end
    links.delete_suffix! ' | '
    links.html_safe
  end

  def show_language_switcher?
    citizen_page? && pages_without_language_switcher.exclude?(request.path)
  end

  def citizen_page?
    session[:journey_type] == :citizens || %r{/assessment_already_completed}.match?(request.path)
  end

  def pages_without_language_switcher
    ['/citizens/gather_transactions']
  end
end
