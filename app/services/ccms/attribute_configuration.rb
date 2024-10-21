module CCMS
  class AttributeConfiguration
    NON_STANDARD_TYPES = %i[non_means_tested non_passported special_children_act].freeze
    VALID_APPLICATION_TYPES = ([:standard] + NON_STANDARD_TYPES).freeze

    attr_reader :config

    # Expects application type of :standard or :non_passported
    def initialize(application_type:)
      raise ArgumentError, "Invalid application type" unless application_type.in?(VALID_APPLICATION_TYPES)

      @config = YAML.load_file(configuration_files[:standard])
      @config.deep_merge! YAML.load_file(configuration_files[application_type]) if application_type.in?(NON_STANDARD_TYPES)
      @config.deep_symbolize_keys!
    end

  private

    def configuration_files
      {
        standard: Rails.root.join("config/ccms/attribute_block_configs/base.yml"),
        non_means_tested: Rails.root.join("config/ccms/attribute_block_configs/non_means_tested.yml"),
        non_passported: Rails.root.join("config/ccms/attribute_block_configs/non_passported.yml"),
        special_children_act: Rails.root.join("config/ccms/attribute_block_configs/special_children_act.yml"),
      }
    end
  end
end
