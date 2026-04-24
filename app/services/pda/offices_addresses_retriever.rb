module PDA
  class OfficesAddressesRetriever
    ApiError = Class.new(StandardError)
    NotFoundError = Class.new(StandardError)

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
      raise ApiError, "API Call Failed retrieving: (#{response.status}) #{response.body}" unless response.success?
      raise NotFoundError, "API Call Failed: Office address not found (#{response.status})" if response.status == 204

      addresses = []
      if response.status == 200
        @office_codes.each do |office_code|
          firms.each do |firm|
            office = firm["offices"].detect { |office| office["firmOfficeCode"] == office_code }
            if office
              addresses << OfficeAddressStruct.new(office_code, { "firm" => firm["firm"], "office" => office })
              break
            end
          end
        end
      end
      addresses
    rescue StandardError => e
      Rails.logger.error("#{self.class} - Error retrieving office address for office codes #{office_codes}: #{e.message}")
      Sentry.capture_message("#{self.class} - #{e.message}")
      raise
    end

    def firms
      @firms || JSON.parse(response.body)
    end

  private

    def response
      @response ||= post("provider-offices", request_body)
    end

    def request_body
      {
        officeCodes: @office_codes,
      }.to_json
    end
  end
end
