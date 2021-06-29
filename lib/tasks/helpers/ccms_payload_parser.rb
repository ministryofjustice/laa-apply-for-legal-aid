class CCMSPayloadParser

  FILENAME = '/Users/stephenrichards/moj/apply/ccms_integration/example_payloads/multi_proc/MP_1333536_NP_multi children.xml'.freeze

  def initialize
    @xml = File.open(FILENAME) { |fp| fp.read }
    @doc = Nokogiri::XML(@xml) { |config| config.noblanks }
    @doc.remove_namespaces!
    @data = @doc.children.first
    @indent_level = 0
    @indent_size = 2
  end
  
  def run
    puts @data.name
    @indent_level = 1
    @data.children.each { |child| process_child(child) }  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  end

  private

  def indent(string)
    puts "#{' ' * (@indent_level * @indent_size)}#{string}"
  end
  
  def process_child(node)
    if text_node?(node)
      display_text(node)
      return
    end

    indent node.name
    @indent_level += 1
    node.children.each { |c| process_child(c) }
    @indent_level -= 1
  end

  def text_node?(node)
    node.children.size == 1 && node.children.first.name == 'text'
  end

  def display_text(node)
    # @indent_level += 1
    indent "#{node.name}:#{node.text}"
    # @indent_level -= 1
  end

end
