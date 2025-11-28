module PDA
  class OfficeAddressRetriever
    ApiError = Class.new(StandardError)

    class OfficeAddressStruct
      attr_reader :code, :address_line_one, :address_line_two, :address_line_three, :address_line_four, :county, :city, :postcode

      def initialize(office_code, office_address_hash = {})
        @code = office_code
        @address_line_one = office_address_hash["addressLine1"]
        @address_line_two = office_address_hash["addressLine2"]
        @address_line_three = office_address_hash["addressLine3"]
        @address_line_four = office_address_hash["addressLine4"]
        @city = office_address_hash["city"]
        @city = office_address_hash["county"]
        @postcode = office_address_hash["postcode"]
      end
    end

    def initialize(office_code)
      @office_code = office_code
    end

    def self.call(office_code)
      new(office_code).call
    end

    def call
      raise ApiError, "API Call Failed retrieving: (#{office_address_response.status}) #{office_address_response.body}" unless office_address_response.success?

      if office_address_response.status == 200
        OfficeAddressStruct.new(@office_code, JSON.parse(office_address_response.body)["office"])
      else
        Rails.logger.info("#{self.class} - No address found for #{@office_code}")
        OfficeAddressStruct.new(@office_code)
      end
    end

  private

    def office_address_response
      @office_address_response ||= pda_conn.get("provider-offices/#{@office_code}")
    end

    def pda_conn
      @pda_conn ||= Faraday.new(url: Rails.configuration.x.pda.url, headers: pda_headers)
    end

    def pda_headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end
  end
end
