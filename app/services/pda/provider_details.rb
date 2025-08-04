module PDA
  class ProviderDetails
    ApiError = Class.new(StandardError)

    # Only save schedule details that are relevant to civily apply
    APPLICABLE_CATEGORIES_OF_LAW = %w[MAT].freeze
    APPLICABLE_AREAS_OF_LAW = ["LEGAL HELP", "CIVIL FUNDING"].freeze

    def initialize(office_code)
      @office_code = office_code
    end

    def self.call(office_code)
      new(office_code).call
    end

    def call
      raise ApiError, "API Call Failed: (#{response.status}) #{response.body}" unless response.success?

      office.schedules.destroy_all
      if response.status == 200
        # update_firm
        # update_office
        create_schedules
        Rails.logger.info("#{self.class} - No applicable schedules found for #{@office_code}") if office.schedules.empty?
      else
        Rails.logger.info("#{self.class} - No schedules found for #{@office_code}")
      end
    end

  private

    def update_firm
      result_firm = result["firm"]
      Firm.find_or_create_by!(ccms_id: result_firm["ccmsFirmId"]).tap do |firm|
        firm.update!(name: result_firm["firmName"])
      end
    end

    def update_office
      result_office = result["office"]
      Office.find_or_create_by!(ccms_id: result_office).tap do |office|
        office.update!(code: result_office["firmOfficeCode"])
      end
    end

    def create_schedules
      result["schedules"].select { |schedule| APPLICABLE_AREAS_OF_LAW.include? schedule["areaOfLaw"] }.each do |result_schedule|
        result_schedule["scheduleLines"].select { |line| APPLICABLE_CATEGORIES_OF_LAW.include? line["categoryOfLaw"] }.each do |result_line|
          Schedule.create!(office_id: office.id,
                           area_of_law: result_schedule["areaOfLaw"],
                           category_of_law: result_line["categoryOfLaw"],
                           authorisation_status: result_schedule["scheduleAuthorizationStatus"],
                           status: result_schedule["scheduleStatus"],
                           cancelled: result_line["cancelFlag"] == "Y",
                           start_date: result_schedule["scheduleStartDate"].to_date,
                           end_date: result_schedule["scheduleEndDate"].to_date,
                           license_indicator: result_line["maximumLicenseCount"],
                           devolved_power_status: result_line["evolvedPowersStatus"])
          Rails.logger.info("#{self.class} - Schedule #{result_schedule['areaOfLaw']} #{result_line['categoryOfLaw']} created for #{@office_code}")
        end
      end
    end

    def result
      JSON.parse(response.body)
    end

    def url
      @url ||= "#{Rails.configuration.x.pda.url}/provider-offices/#{@office_code}/schedules"
    end

    def headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def response
      @response ||= query_api
    end

    def office
      @office = Office.find_by(code: @office_code)
    end

    def query_api
      conn.get url
    end
  end
end
