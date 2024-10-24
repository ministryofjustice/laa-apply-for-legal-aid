module CCMS
  module Requestors
    class SpecialChildrenActCaseAddRequestor < NonMeansTestedCaseAddRequestor
      wsdl_from Rails.configuration.x.ccms_soa.caseServicesWsdl

    private

      def means_entity_config_file
        MEANS_ENTITY_CONFIG_DIR.join("non_means_tested.yml")
      end

      def attribute_configuration
        AttributeConfiguration.new(application_type: :special_children_act).config
      end
    end
  end
end
