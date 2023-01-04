module CCMS
  module Requestors
    class NonMeansTestedCaseAddRequestor < CaseAddRequestor
      wsdl_from Rails.configuration.x.ccms_soa.caseServicesWsdl

    private

      def means_entity_config_file
        MEANS_ENTITY_CONFIG_DIR.join("non_means_tested.yml")
      end

      def attribute_configuration
        AttributeConfiguration.new(application_type: :non_means_tested).config
      end
    end
  end
end
