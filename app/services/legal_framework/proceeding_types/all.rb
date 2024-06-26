module LegalFramework
  module ProceedingTypes
    class All < BaseApiCall
      class ProceedingTypeStruct
        attr_reader :ccms_code, :meaning, :description, :ccms_category_law, :ccms_matter_code, :ccms_matter, :sca_core, :sca_related

        def initialize(pt_hash)
          @ccms_code = pt_hash["ccms_code"]
          @meaning = pt_hash["meaning"]
          @description = pt_hash["description"]
          @ccms_category_law = pt_hash["ccms_category_law"]
          @ccms_matter_code = pt_hash["ccms_matter_code"]
          @ccms_matter = pt_hash["ccms_matter"]
          @sca_core = pt_hash["sca_core"]
          @sca_related = pt_hash["sca_related"]
        end

        def not_sca?
          [@sca_core, @sca_related].all?(false)
        end
      end

      def initialize(params)
        super()
        @provider = params[:provider]
      end

      def call
        Setting.special_childrens_act? ? unfiltered_payload : filtered_payload
      end

      def path
        "/proceeding_types/all"
      end

    private

      def unfiltered_payload
        JSON.parse(request.body).map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

      def filtered_payload
        unfiltered_payload.select(&:not_sca?)
      end
    end
  end
end
