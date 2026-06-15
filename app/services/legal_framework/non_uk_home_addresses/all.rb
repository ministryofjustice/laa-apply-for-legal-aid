module LegalFramework
  module NonUkHomeAddresses
    class All < LegalFramework::BaseApiCall
      class CountryNames
        attr_reader :code, :description

        def initialize(country_names_hash)
          @code = country_names_hash["code"]
          @description = country_names_hash["description"]
        end
      end

      def call
        JSON.parse(cached_response).map { |cn_hash| CountryNames.new(cn_hash) }
      end

      def path
        "/countries/all"
      end

    private

      def cached_response
        read_or_store_values { request.body }
      end

      def redis_key
        "lfa/countries"
      end
    end
  end
end
