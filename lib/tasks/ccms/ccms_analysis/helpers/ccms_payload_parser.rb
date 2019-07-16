module CCMS
  class PayloadParser
    def initialize
      @doc = File.open(Rails.root.join('ccms_integration/example_payloads/PassportedSingleProceedingNonMolDelegated.xml')) { |f| Nokogiri::XML(f).remove_namespaces! }
    end

    def run
      puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<\n"

      x = @doc.xpath('//Attributes//Attribute//Attribute')
      attrs = []

      x.each { |z| attrs << z.text }
      attrs.sort!
      pp attrs
    end
  end
end
