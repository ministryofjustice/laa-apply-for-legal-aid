module LegalFramework
  module NonUkCorrespondenceAddresses
    class All < LegalFramework::BaseApiCall
      class CountryNames
        attr_reader :code, :description

        def initialize(country_names_hash)
          @code = country_names_hash["code"]
          @description = country_names_hash["description"]
        end
      end

      def call
        parsed_payload
      end

      def path
        "/countries/all"
      end

    private

      def parsed_payload
        JSON.parse(request.body).map { |cn_hash| CountryNames.new(cn_hash) }
      end
    end
  end
end
