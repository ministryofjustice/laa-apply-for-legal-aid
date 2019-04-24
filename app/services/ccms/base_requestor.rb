module CCMS
  class BaseRequestor
    def initialize(wsdl_location, namespaces)
      @soap_client = Savon.client(
        env_namespace: :soap,
        wsdl: wsdl_location,
        namespaces: namespaces,
        pretty_print_xml: true,
        convert_request_keys_to: :none,
        namespace_identifier: 'ns2',
        log: true
      )
      @transaction_request_id = nil
    end

    def request_xml
      message.to_xml
    end

    def formatted_xml
      result = ''
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      formatter.write(REXML::Document.new(request_xml), result)
      result
    end

    def transaction_request_id
      @transaction_request_id ||= Time.now.strftime('%Y%m%d%H%M%S%6N') + rand.to_s[2..8]
    end

    private

    def soap_header(xml)
      xml.__send__('ns1:Security') do
        xml.__send__('ns1:UsernameToken') do
          xml.__send__('ns1:Username', ENV['SOAP_CLIENT_USERNAME'])
          xml.__send__('ns1:Password', 'Type' => ENV['SOAP_CLIENT_PASSWORD_TYPE'] ) { xml.text ENV['SOAP_CLIENT_PASSWORD'] }
        end
      end
    end


    def header_message
      {
        'ns1:Security' => {
          'ns1:UsernameToken' => {
            'ns1:Username' => ENV['SOAP_CLIENT_USERNAME'],
            'ns1:Password' => {
              '@Type' => ENV['SOAP_CLIENT_PASSWORD_TYPE'],
              content!: ENV['SOAP_CLIENT_PASSWORD']
            }
          }
        }
      }
    end
  end
end
