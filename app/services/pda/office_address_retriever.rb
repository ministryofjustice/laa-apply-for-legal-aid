module PDA
  class OfficeAddressRetriever
    ApiError = Class.new(StandardError)
    NotFoundError = Class.new(StandardError)

    class OfficeAddressStruct
      attr_reader :code, :firm_name, :address_line_one, :address_line_two, :address_line_three, :address_line_four, :county, :city, :post_code

      def initialize(office_code, office_address_hash = {})
        @code = office_code
        @firm_name = office_address_hash.dig("firm", "firmName")
        @address_line_one = office_address_hash.dig("office", "addressLine1")
        @address_line_two = office_address_hash.dig("office", "addressLine2")
        @address_line_three = office_address_hash.dig("office", "addressLine3")
        @address_line_four = office_address_hash.dig("office", "addressLine4")
        @city = office_address_hash.dig("office", "city")
        @county = office_address_hash.dig("office", "county")
        @post_code = office_address_hash.dig("office", "postCode")
      end
    end

    attr_reader :office_code, :connection

    delegate :get, to: :connection

    def initialize(office_code, connection: PDA::Connection.new)
      @office_code = office_code
      @connection = connection
    end

    def self.call(office_code, **)
      new(office_code, **).call
    end

    # Ideally the PDA would return a 404 if the office address is not found, but it currently returns a 204
    def call
      raise ApiError, "API Call Failed retrieving: (#{response.status}) #{response.body}" unless response.success?
      raise NotFoundError, "API Call Failed: Office address not found (#{response.status})" if response.status == 204

      address if response.status == 200
    rescue StandardError => e
      Rails.logger.error("#{self.class} - Error retrieving office address for office code #{office_code}: #{e.message}")
      Sentry.capture_message("#{self.class} - #{e.message}")
      raise
    end

  private

    def address
      @address ||= OfficeAddressStruct.new(office_code, office_address_hash || {})
    end

    def office_address_hash
      @office_address_hash ||= JSON.parse(response.body)
    end

    def response
      @response ||= get("provider-offices/#{@office_code}")
    end
  end
end
