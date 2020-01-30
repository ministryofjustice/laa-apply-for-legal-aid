module CCMS
  module Requestors
    class BaseRequestor
      class << self
        attr_reader :wsdl, :namespaces

        def wsdl_from(filename)
          @wsdl = filename
        end

        def uses_namespaces(namespaces)
          @namespaces = namespaces.freeze
        end
      end

      def formatted_xml
        result = ''
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(REXML::Document.new(request_xml), result)
        result
      end

      def transaction_request_id
        @transaction_request_id ||= Time.current.strftime('%Y%m%d%H%M%S%6N') + rand.to_s[2..8]
      end

      private

      # temporarily ignore this until connectivity with ccms is working
      # :nocov:
      def soap_client
        @soap_client ||= Savon.client(
          headers: { 'x-api-key' => config.aws_gateway_api_key },
          env_namespace: :soap,
          wsdl: wsdl_location,
          namespaces: namespaces,
          pretty_print_xml: true,
          convert_request_keys_to: :none,
          namespace_identifier: 'ns2',
          log: false,
          log_level: :debug
        )
      end
      # :nocov:

      def soap_envelope(namespaces)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.__send__('soap:Envelope', namespaces) do
            xml.__send__('soap:Header') { soap_header(xml) }
            xml.__send__('soap:Body') { soap_body(xml) }
          end
        end
      end

      def soap_header(xml)
        xml.__send__('ns1:Security') do
          xml.__send__('ns1:UsernameToken') do
            xml.__send__('ns1:Username', config.client_username)
            xml.__send__('ns1:Password', 'Type' => config.client_password_type) do
              xml.text(config.client_password)
            end
          end
        end
      end

      def ns3_header_rq(xml, provider_username)
        xml.__send__('ns3:TransactionRequestID', transaction_request_id)
        xml.__send__('ns3:Language', 'ENG')
        xml.__send__('ns3:UserLoginID', provider_username)
        xml.__send__('ns3:UserRole', config.user_role)
      end

      def wsdl_location
        Rails.root.join('app/services/ccms/wsdls/', self.class.wsdl.to_s).to_s
      end

      def namespaces
        self.class.namespaces
      end

      def config
        Rails.configuration.x.ccms_soa
      end
    end
  end
end
