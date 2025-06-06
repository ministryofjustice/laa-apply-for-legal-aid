module LegalFramework
  module ProceedingTypes
    class All < BaseApiCall
      class NoMatchingProceedingsFoundError < StandardError; end

      class ProceedingTypeStruct
        attr_reader :ccms_code, :meaning, :description, :ccms_category_law, :ccms_matter_code, :ccms_matter, :sca_core, :sca_related, :plf

        def initialize(pt_hash)
          @ccms_code = pt_hash["ccms_code"]
          @meaning = pt_hash["meaning"]
          @description = pt_hash["description"]
          @ccms_category_law = pt_hash["ccms_category_law"]
          @ccms_matter_code = pt_hash["ccms_matter_code"]
          @ccms_matter = pt_hash["ccms_matter"]
          @sca_core = pt_hash["sca_core"]
          @sca_related = pt_hash["sca_related"]
          @plf = pt_hash["ccms_matter_code"] == "KPBLB"
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
        parsed_body = JSON.parse(request.body)
        parsed_body["data"].map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

    private

      def request_body
        {
          current_proceedings: @legal_aid_application.proceedings&.map(&:ccms_code),
          allowed_categories: %w[MAT], # TODO: replace with details from new PDA, for now hardcoded to only current category type
          search_term: "", # TODO: add optional parameter to the initializer, but for now leave always empty
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
