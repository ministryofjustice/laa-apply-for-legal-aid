class SummaryListRow
  def initialize(key, value)
    @key = key
    @value = value
  end

  def matches?(page)
    @summary_list = page.find("dl.govuk-summary-list")
    summary_list_key = @summary_list.find("dt", text: @key)
    summary_list_key.sibling("dd").text == @value
  end

  def failure_message
    "Expected to find a summary list row with key '#{@key}' and value " \
      "'#{@value}' in #{@summary_list.native.inner_html}."
  end
end
