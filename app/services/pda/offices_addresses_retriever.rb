module PDA
  class OfficesAddressesRetriever
    ApiError = Class.new(StandardError)

    class OfficeAddressStruct
      attr_reader :code, :address_line_one, :address_line_two, :address_line_three, :address_line_four, :county, :city, :post_code

      def initialize(office_code, office_address_hash = {})
        @code = office_code
        @address_line_one = office_address_hash["addressLine1"]
        @address_line_two = office_address_hash["addressLine2"]
        @address_line_three = office_address_hash["addressLine3"]
        @address_line_four = office_address_hash["addressLine4"]
        @city = office_address_hash["city"]
        @county = office_address_hash["county"]
        @post_code = office_address_hash["postCode"]
      end
    end

    attr_reader :office_codes, :connection

    delegate :post, to: :connection

    def initialize(office_codes, connection: PDA::Connection.new)
      @office_codes = office_codes
      @connection = connection
    end

    def self.call(office_codes)
      new(office_codes).call
    end

    def call
      raise ApiError, "API Call Failed retrieving: (#{office_address_response.status}) #{office_address_response.body}" unless office_address_response.success?

      addresses = []
      if office_address_response.status == 200
        @office_codes.each do |office_code|
          addresses << OfficeAddressStruct.new(office_code, offices.detect { |office| office["firmOfficeCode"] == office_code } || {})
        end
      end
      addresses
    end

    def firms
      @firms || JSON.parse(office_address_response.body)
    end

    def offices
      offices = firms.pluck("offices")
      offices.flatten
    end

  private

    def office_address_response
      @office_address_response ||= post("provider-offices", request_body)
    end

    def request_body
      {
        officeCodes: @office_codes,
      }.to_json
    end

    def response
      @response ||= "provider-offices"
    end
  end
end
