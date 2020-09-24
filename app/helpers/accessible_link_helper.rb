module AccessibleLinkHelper
  def link_to_with_hidden_suffix(path:, text:, suffix:, klass: nil)
    link_to(path, class: klass) do
      "#{text}<span class='govuk-visually-hidden'> #{suffix}</span>".html_safe
    end
  end
end
