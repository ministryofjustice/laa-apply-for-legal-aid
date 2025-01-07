# frozen_string_literal: true

module HashFormatHelper
  # These methods add classes to the HTML structure
  def format_hash(hash, html = "")
    hash.each do |key, value|
      next if value.blank?

      if value.is_a?(Array)
        html += build_dl_array(key, value)
      elsif standard_type?(value) || value.is_a?(Hash)
        html += build_dl(key, value)
      else
        Rails.logger.info "Unexpected value type of '#{value.class.name}' for key '#{standardize_key(key)}' in format_hash: #{value.inspect}"
      end
    end
    html.html_safe
  end

private

  def build_dl_array(key, value)
    content_tag(:dl, class: "govuk-body kvp govuk-!-margin-bottom-0") do
      dl_contents = +""
      dl_contents << content_tag(:dt, standardize_key(key))
      value.each do |val|
        dl_contents << if val.is_a?(Hash)
                         format_hash(val)
                       else
                         content_tag(:dd, val)
                       end
      end
      dl_contents.html_safe
    end
  end

  def build_dl(key, value)
    content_tag(:dl, class: "govuk-body kvp govuk-!-margin-bottom-0") do
      dl_contents = +""
      dl_contents << content_tag(:dt, standardize_key(key))
      dl_contents << if standard_type?(value)
                       content_tag(:dd, value.to_s.capitalize)
                     else
                       format_hash(value)
                     end
      dl_contents.html_safe
    end
  end

  def standardize_key(key)
    key.to_s.underscore.humanize.titleize
  end

  def standard_type?(value)
    value.is_a?(String) || value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
  end
end
