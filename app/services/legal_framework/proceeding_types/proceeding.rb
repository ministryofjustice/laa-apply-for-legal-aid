module LegalFramework
  module ProceedingTypes
    class Proceeding < LegalFramework::BaseApiCall
      class Response
        attr_reader :success,
                    :ccms_code,
                    :meaning,
                    :ccms_category_law_code,
                    :ccms_matter_code,
                    :name,
                    :description,
                    :ccms_category_law,
                    :ccms_matter,
                    :cost_limitations,
                    :default_scope_limitations,
                    :service_levels,
                    :sca_type

        def initialize(json_response)
          response = JSON.parse(json_response)
          @success = response["success"]
          @ccms_code = response["ccms_code"]
          @meaning = response["meaning"]
          @ccms_category_law_code = response["ccms_category_law_code"]
          @ccms_matter_code = response["ccms_matter_code"]
          @name = response["name"]
          @description = response["description"]
          @ccms_category_law = response["ccms_category_law"]
          @ccms_matter = response["ccms_matter"]
          @cost_limitations = response["cost_limitations"]
          @default_scope_limitations = response["default_scope_limitations"]
          @service_levels = response["service_levels"]
          @sca_type = generate_sca_type(response)
        end

        def generate_sca_type(response)
          return "core" if response["sca_core"]
          return "related" if response["sca_related"]

          nil
        end
      end

      def self.call(ccms_code)
        new(ccms_code).call
      end

      def initialize(ccms_code)
        super()
        @ccms_code = ccms_code
      end

      def call
        Response.new(request.body)
      end

    private

      def path
        "/proceeding_types/#{@ccms_code}"
      end
    end
  end
end
