module CCMS
  module PayloadGenerators
    # This class is responsible for generating the series of attribute blocks for an entity
    #
    class EntityAttributesGenerator
      delegate :ccms_attribute_keys, :submission, to: :requestor

      attr_reader :requestor

      CONFIG_METHOD_REGEX = /^#(\S+)/.freeze

      def self.call(requestor, xml, entity_name, options = {})
        new(requestor, xml, entity_name, options).call
      end

      def initialize(requestor, xml, entity_name, options)
        @xml = xml
        @entity_name = entity_name
        @requestor = requestor
        @options = options
        @attr_config = ccms_attribute_keys[@entity_name]
      end

      def call
        @attr_config.each do |attribute_name, config|
          next unless generate_attribute_block?(config)

          response_value = extract_response_value(config)
          @xml.__send__('ns0:Attribute') do
            @xml.__send__('ns0:Attribute', attribute_name)
            @xml.__send__('ns0:ResponseType', config[:response_type])
            @xml.__send__('ns0:ResponseValue', response_value)
            @xml.__send__('ns0:UserDefinedInd', config[:user_defined])
          end
        end
      end

      private

      def attribute_value_generator
        @attribute_value_generator ||= AttributeValueGenerator.new(submission)
      end

      def generate_attribute_block?(config)
        config.key?(:generate_block?) ? evaluate_generate_block_method(config) : true
      end

      def evaluate_generate_block_method(config)
        return config[:generate_block?] if boolean?(config[:generate_block?])

        method_name = config[:generate_block?].sub(/^#/, '')
        attribute_value_generator.__send__(method_name, @options)
      end

      def boolean?(value)
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end

      def extract_response_value(config)
        raw_value = extract_raw_value(config)
        case config[:response_type]
        when 'text', 'number', 'boolean'
          raw_value
        when 'currency'
          as_currency(raw_value)
        when 'date'
          raw_value.is_a?(Date) ? raw_value.strftime('%d-%m-%Y') : raw_value
        else
          raise CCMSError, "Submission #{submission.id} - Unknown response type in attributes config yaml file: #{config[:response_type]}"
        end
      rescue StandardError => e
        Raven.capture_message("EntityAttributesGenerator #{e.class}: #{e.message} with config.inspect values of: #{config.inspect}")
        raise
      end

      def extract_raw_value(config)
        if config[:value] == true || config[:value] == false
          config[:value]
        else
          method_name?(config[:value]) ? get_attr_value(config[:value]) : config[:value]
        end
      end

      def method_name?(str)
        return false unless str.is_a?(String)

        CONFIG_METHOD_REGEX.match?(str)
      end

      def get_attr_value(str)
        attribute_value_generator.__send__(method_name(str), @options)
      end

      def method_name(str)
        str.sub(/^#/, '')
      end

      def as_currency(raw_value)
        format('%<amount>.2f', amount: raw_value)
      end
    end
  end
end
