CHANGE_LINKS_CONTAINING_UUIDS = %i[success_likely].freeze

RSpec::Matchers.define :have_change_link do |field_name, expected_link|
  match do |actual|
    @uuid = expected_link.match(/(?<=merits_task_list\/)(.*)(?=\/)/).to_s
    link = extract_link(actual, formatted_field_name(field_name))
    link == expected_link
  end
  failure_message do |actual|
    link = extract_link(actual, field_name)
    if link.nil?
      "Expected to find change link for #{field_name}, but none found"
    else
      "Expected change link for #{field_name} to be #{expected_link}, was #{link}"
    end
  end

  def extract_link(html, field_name)
    links = parsed_response_body(html).css("div#app-check-your-answers__#{field_name} a")
    links.first&.attr("href")
  end

  def formatted_field_name(field_name)
    CHANGE_LINKS_CONTAINING_UUIDS.include?(field_name) ? "#{@uuid}_#{field_name}" : field_name
  end
end
