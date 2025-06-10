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

      def self.call(legal_aid_application = nil)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        super()
        @legal_aid_application = legal_aid_application
      end

      def call
        response = request
        parsed_body = JSON.parse(response.body)
        data = show_all_proceedings? ? parsed_body : parsed_body["data"]
        data.map { |pt_hash| ProceedingTypeStruct.new(pt_hash) }
      end

    private

      def request_body
        return if show_all_proceedings?

        {
          current_proceedings: @legal_aid_application.proceedings&.map(&:ccms_code),
          allowed_categories: %w[MAT], # TODO: replace with details from new PDA, for now hardcoded to only current category type
          search_term: "", # TODO: add optional parameter to the initializer, but for now leave always empty
        }.to_json
      end

      def request
        conn.send(request_method) do |request|
          request.url path
          request.headers["Content-Type"] = "application/json"
          request.body = request_body unless show_all_proceedings?
        end
      end

      def request_method
        show_all_proceedings? ? :get : :post
      end

      def show_all_proceedings?
        @legal_aid_application.blank?
      end

      def path
        show_all_proceedings? ? "/proceeding_types/all" : "/proceeding_types/filter"
      end

      def headers
        {
          "Content-Type" => "application/json",
        }
      end
    end
  end
end
