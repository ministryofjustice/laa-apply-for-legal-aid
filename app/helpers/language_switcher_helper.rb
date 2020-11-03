module LanguageSwitcherHelper
  def language_links
    links = ''

    I18n.available_locales.each do |locale|
      link = I18n.locale == locale ? t("generic.#{locale}") : link_to(t("generic.#{locale}"), url_for(locale: locale))
      links << "#{link} | "
    end
    links.delete_suffix! ' | '
    links.html_safe
  end
end
