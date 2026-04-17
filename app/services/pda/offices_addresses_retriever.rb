module PDA
  class OfficesAddressesRetriever
    ApiError = Class.new(StandardError)

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
