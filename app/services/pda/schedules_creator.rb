module PDA
  class SchedulesCreator
    ApiError = Class.new(StandardError)

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
        result = JSON.parse(response.body)
        result["schedules"].each do |schedule|
          schedule["scheduleLines"].each do |schedule_line|
            Schedule.create!(office_id: office.id,
                             area_of_law: schedule["areaOfLaw"],
                             category_of_law: schedule_line["categoryOfLaw"],
                             authorisation_status: schedule["scheduleAuthorizationStatus"],
                             status: schedule["scheduleStatus"],
                             start_date: Date.parse(schedule["scheduleStartDate"]),
                             end_date: Date.parse(schedule["scheduleEndDate"]))
          end
        end
      end
    end

  private

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
