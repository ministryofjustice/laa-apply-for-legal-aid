require "nokogiri"

RSpec::Matchers.define :have_xml do |xpath, text|
  results = []

  match do
    nodes = xml_doc.xpath(xpath)

    return false if nodes.empty?

    if text
      nodes.each do |node|
        results << (node.content == text)
      end
    end

    results.any?(true)
  end

  failure_message do
    "expected to find one or more xml tags \"#{xpath}\" containing \"#{text}\""
  end

  failure_message_when_negated do
    "expected not to find xml tag #{xpath}"
  end

  description do
    "have xml tag #{xpath}"
  end

  def xml_doc
    if actual.is_a?(Nokogiri::XML::Builder)
      actual.doc
    else
      Nokogiri::XML::Document.parse(actual)
    end
  end
end
