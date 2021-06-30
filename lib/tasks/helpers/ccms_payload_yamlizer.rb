require 'nokogiri'
require 'yaml'

class CcmsPayloadYamlizer
  def initialize(filename)
    @xml = File.open(filename, &:read)
    @doc = Nokogiri::XML(@xml, &:noblanks)
    @doc.remove_namespaces!
    @data = @doc.children.first
    @hash = {}
  end

  def run
    @hash[@data.name] = {}
    @data.children.each { |child| process_child(child, @hash[@data.name]) }
    # rubocop:disable Rails/Output
    puts @hash.to_yaml
    # rubocop:enable Rails/Output
  end

  private

  def process_child(node, hash)
    if attribute_block(node)
      key, value = extract_details_from_attribute_block(node)
      hash[key] = value
      return
    end
    if text_node?(node)
      hash[node.name] = node.text
      return
    end

    key = calculate_new_key(hash, node.name)

    hash[key] = {}
    node.children.each { |c| process_child(c, hash[key]) }
  end

  def text_node?(node)
    node.children.size == 1 && node.children.first.name == 'text'
  end

  def calculate_new_key(hash, node_name)
    node_name = increment_node_name(node_name) while hash.key?(node_name)
    node_name
  end

  def increment_node_name(node_name)
    if node_name =~ /^\S+\[(\d+)\]$/
      node_name.sub(/\[\d+\]/, "[#{Regexp.last_match(1).to_i + 1}]")
    else
      "#{node_name}[1]"
    end
  end

  def attribute_block(node)
    return if node.name != 'Attribute'

    return unless node.children.map(&:name).sort == %w[Attribute ResponseType ResponseValue UserDefinedInd]

    true
  end

  def extract_details_from_attribute_block(node)
    key = node.xpath('Attribute').text
    val = node.xpath('ResponseValue').text
    type = node.xpath('ResponseType').text
    user_def = node.xpath('UserDefinedInd').text
    [key, "#{type}:#{val}:#{user_def}"]
  end
end
