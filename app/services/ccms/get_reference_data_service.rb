module CCMS
  class GetReferenceDataService

    NAMESPACES = {
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM',
      'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
      'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
      'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO'
    }

    WSDL_LOCATION = '/Users/stephenrichards/moj/apply/app/services/ccms/wsdls/GetReferenceDataWsdl.xml'
    SOAP_CLIENT_USERNAME = ENV['SOAP_CLIENT_USERNAME']
    SOAP_CLIENT_PASSWORD_TYPE = ENV['SOAP_CLIENT_PASSWORD_TYPE']
    SOAP_CLIENT_PASSWORD = ENV['SOAP_CLIENT_PASSWORD']
    USER_LOGIN = ENV['USER_LOGIN']
    USER_ROLE = ENV['USER_ROLE']

    def initialize
      @soap_client ||= Savon.client(
        env_namespace: :soap,
        wsdl: WSDL_LOCATION,
        namespaces: NAMESPACES,
        pretty_print_xml: true,
        convert_request_keys_to: :none,
        namespace_identifier: 'ns2',
        log: true
      )
    end


    def operations
      @soap_client.operations
    end
    
    def call
      @soap_client.call(:process, soap_header: header_message, message: body_message)
    end


    def print_xml
      request = @soap_client.build_request(:process, soap_header: header_message, message: body_message)
      puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
      puts request.body
      puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
      rexml_print(request)
    end

    private

    def rexml_print(request)
      require 'rexml/document'
      doc = REXML::Document.new(request.body)
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
      formatter.write(doc, $stdout)
      puts " "
      puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
    end

    def message
      {
        'soap:Header' => header_message,
        'soap:Body' => body_message
      }
    end

    def header_message
      {
        'ns1:Security' => {
          'ns1:UsernameToken' => {
            'ns1:Username' => SOAP_CLIENT_USERNAME,
            'ns1:Password' => {
              '@Type'=> SOAP_CLIENT_PASSWORD_TYPE,
              content!: SOAP_CLIENT_PASSWORD
            }
          }
        }
      }
    end

    def body_message
     body =  {
       'ns3:HeaderRQ' => header_request,
        'ns2:SearchCriteria' => search_criteria
      }
    end


    def header_request
      {
        'ns3:TransactionRequestID' => generate_transaction_request_id,
        'ns3:Language' => 'ENG',
        'ns3:UserLoginID' => USER_LOGIN,
        'ns3:UserRole' => USER_ROLE
      }
    end

    def search_criteria
      {
        'ns5:ContextKey' => 'CaseReferenceNumber',
        'ns5:SearchKey' => {
          'ns5:Key' => 'CaseReferenceNumber'
        }
      }
    end

    def generate_transaction_request_id
      Time.now.strftime('%Y%m%d%H%M%S%6N')
    end
  end
end
