module LegalFramework
  module ProceedingTypes
    class All < BaseApiCall
      class ProceedingTypeStruct
        attr_reader :ccms_code, :meaning, :description, :ccms_category_law, :ccms_matter_code, :ccms_matter

        def initialize(pt_hash)
          @ccms_code = pt_hash["ccms_code"]
          @meaning = pt_hash["meaning"]
          @description = pt_hash["description"]
          @ccms_category_law = pt_hash["ccms_category_law"]
          @ccms_matter_code = pt_hash["ccms_matter_code"]
          @ccms_matter = pt_hash["ccms_matter"]
        end
      end

      def initialize(params)
        super()
        @provider = params[:provider]
      end

      def call
        parsed_payload
      end

      def path
        "/proceeding_types/all"
      end

    private

      def parsed_payload
        JSON.parse(request.body).map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end
    end
  end
end
