module PDA
  class OfficeAddressRetriever
    ApiError = Class.new(StandardError)
    NotFoundError = Class.new(StandardError)

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
