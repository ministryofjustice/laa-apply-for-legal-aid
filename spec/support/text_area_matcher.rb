RSpec::Matchers.define :have_text_area_with_id_and_content do |expected_id, expected_content|
  match do |actual|
    text_area = extract_text_area(actual, expected_id)
    if text_area.empty?
      false
    else
      text_area.text.sub(/^\n/, '') == expected_content
    end
  end

  failure_message do |actual|
    text_area = extract_text_area(actual, expected_id)
    if text_area.empty?
      "Expected to find textarea tag with id #{expected_id}: none found"
    else
      "Expected content of textarea to be:\n#{expected_content}\nwas:\n#{text_area.first.text}"
    end
  end

  def extract_text_area(html, id)
    parsed_response_body(html).css("textarea##{id}")
  end
end
