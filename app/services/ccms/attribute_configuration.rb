module CCMS
  class AttributeConfiguration
    VALID_APPLICATION_TYPES = %i[standard non_passported].freeze

    attr_reader :config

    # Expects application type of :standard or :non_passported
    def initialize(application_type:)
      raise ArgumentError, 'Invalid application type' unless application_type.in?(VALID_APPLICATION_TYPES)

      @config = YAML.load_file(configuration_files[:standard])
      @config.deep_merge! YAML.load_file(configuration_files[application_type]) if application_type == :non_passported
      @config.deep_symbolize_keys!
    end

    private

    def configuration_files
      {
        standard: Rails.root.join('config/ccms/attribute_block_configs/base.yml'),
        non_passported: Rails.root.join('config/ccms/attribute_block_configs/non_passported.yml')
      }
    end
  end
end
