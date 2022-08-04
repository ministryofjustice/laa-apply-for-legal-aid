module LegalFramework
  module ProceedingTypes
    class All < BaseApiCall
      class ProceedingTypeStruct
        attr_reader :ccms_code, :meaning, :description, :ccms_category_law, :ccms_matter_code, :ccms_matter, :full_s8_only

        def initialize(pt_hash)
          @ccms_code = pt_hash["ccms_code"]
          @meaning = pt_hash["meaning"]
          @description = pt_hash["description"]
          @ccms_category_law = pt_hash["ccms_category_law"]
          @ccms_matter_code = pt_hash["ccms_matter_code"]
          @ccms_matter = pt_hash["ccms_matter"]
          @full_s8_only = pt_hash["full_s8_only"]
        end

        def not_full_s8_only?
          @full_s8_only == false
        end
      end

      def initialize(params)
        super()
        @provider = params[:provider]
      end

      def call
        @provider.full_section_8_permissions? ? parsed_payload : filtered_parsed_payload
      end

      def path
        "/proceeding_types/all"
      end

    private

      def parsed_payload
        JSON.parse(request.body).map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

      def filtered_parsed_payload
        parsed_payload.select(&:not_full_s8_only?)
      end
    end
  end
end
