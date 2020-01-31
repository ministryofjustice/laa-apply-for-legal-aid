module CCMS
  class AttributeConfiguration
    VALID_APPLICATION_TYPES = %i[standard non_passported].freeze

    attr_reader :config

    # Expects application type of :standard or :non_passported
    def initialize(application_type:)
      raise ArgumentError, 'Invalid application type' unless application_type.in?(VALID_APPLICATION_TYPES)

      @config = YAML.load_file(configuration_files[:standard])
      @config.deep_merge! YAML.load_file(configuration_files[application_type]) if application_type != :standard
    end

    private

    def configuration_files
      {
        standard: File.join(Rails.root, 'config', 'ccms', 'standard_ccms_keys.yml'),
        non_passported: File.join(Rails.root, 'config', 'ccms', 'non_passported_ccms_keys.yml')
      }
    end
  end
end
