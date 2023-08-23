require "nokogiri"

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |body|
    doc = Nokogiri::XML::Document.parse(body)
    nodes = doc.xpath(xpath)

    return false if nodes.empty?

    results = []

    if text
      nodes.each do |node|
        results << (node.content == text)
      end
    end

    results.any?(true)
  end

  failure_message do
    "expected to find one or more xml tags \"#{xpath}\" containing \"#{text}\" \n"
  end

  failure_message_when_negated do
    "expected not to find xml tag #{xpath}"
  end

  description do
    "have xml tag #{xpath}"
  end
end
