module LegalFramework
  module ProceedingTypes
    class Filter < BaseApiCall
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

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        super()
        @legal_aid_application = legal_aid_application
      end

      def call
        JSON.parse(request.body).map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

    private

      def request_body
        {
          current_proceedings: @legal_aid_application.proceedings&.map(&:ccms_code)&.join(","),
          allowed_categories: %w[MAT], # hardcoded to only current matter types
          search_term: "", # always empty for now
        }.to_json
      end

      def request
        conn.post do |request|
          request.url url
          request.headers["Content-Type"] = "application/json"
          request.body = request_body
        end
      end

      def path
        "/proceeding_types/filter"
      end

      def headers
        {
          "Content-Type" => "application/json",
        }
      end
    end
  end
end
