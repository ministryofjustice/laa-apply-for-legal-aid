module PDA
  class ProviderDetailsUpdater
    ApiError = Class.new(StandardError)
    UserNotFound = Class.new(StandardError)

    # Only save schedule details that are relevant to civil apply
    APPLICABLE_CATEGORIES_OF_LAW = %w[MAT].freeze
    APPLICABLE_AREAS_OF_LAW = ["LEGAL HELP"].freeze

    def initialize(provider, office_code)
      @provider = provider
      @office_code = office_code
    end

    def self.call(provider, office_code)
      new(provider, office_code).call
    end

    def call
      raise ApiError, "API Call Failed retrieving office schedules: (#{office_schedules_response.status}) #{office_schedules_response.body}" unless office_schedules_response.success?

      destroy_existing_schedules

      # TODO??: create/update firm and office if they exists in PDA at all rather than if exists WITH a schedule??
      # Since schedules can expire we would eventually have offices without active schedules anyway so why not just create
      # and update the firm/office regardless, then handle schedule logic
      if office_schedules_response.status == 200
        update_firm
        update_office
        update_provider
        create_schedules
        Rails.logger.info("#{self.class} - No applicable schedules found for #{@office_code}") if office.schedules.empty?
      else
        Rails.logger.info("#{self.class} - No schedules found for #{@office_code}")
      end
    end

    def has_valid_schedules?
      return false if schedules.nil?

      schedules.any? do |schedule|
        ScheduleValidator.call(schedule)
      end
    end

  private

    def destroy_existing_schedules
      Office.find_by(code: @office_code)&.schedules&.destroy_all
    end

    def firm
      @firm ||= Firm.find_or_create_by!(ccms_id: office_schedules_result.dig("firm", "ccmsFirmId"))
    end

    def office
      @office = Office.find_or_initialize_by(code: @office_code)
    end

    def schedules
      @schedules ||= office.schedules
    end

    def update_firm
      firm.update!(name: office_schedules_result.dig("firm", "firmName"))
    end

    def update_office
      office.update!(ccms_id: office_schedules_result.dig("office", "ccmsFirmOfficeId"), firm:)
    end

    def update_provider
      @provider.firm = firm
      @provider.offices << office unless @provider.offices.include?(office)
      @provider.selected_office_id = office.id
      @provider.contact_id = contact_id
      @provider.save!
    end

    def create_schedules
      office_schedules_result["schedules"].select { |schedule| APPLICABLE_AREAS_OF_LAW.include? schedule["areaOfLaw"] }.each do |result_schedule|
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
                           devolved_power_status: result_line["devolvedPowersStatus"])
          Rails.logger.info("#{self.class} - Schedule #{result_schedule['areaOfLaw']} #{result_line['categoryOfLaw']} created for #{@office_code}")
        end
      end
    end

    def office_schedules_result
      @office_schedules_result ||= JSON.parse(office_schedules_response.body)
    end

    def contact_id
      if user_detail_response.success?
        if user_detail_response.status == 200
          JSON.parse(user_detail_response.body).dig("user", "ccmsContactId")
        else
          Rails.logger.info("#{self.class} - No provider details found for #{@provider.email}")
          raise UserNotFound, "No CCMS username found for #{@provider.email}"
        end
      else
        raise ApiError, "API Call Failed: provider-users (#{user_detail_response.status}) #{user_detail_response.body}"
      end
    end

    def office_schedules_response
      @office_schedules_response ||= conn.get("provider-offices/#{@office_code}/schedules")
    end

    def user_detail_response
      @user_detail_response ||= conn.get("provider-users/#{encoded_username}")
    end

    def encoded_username
      @encoded_username ||= URI.encode_www_form_component(@provider.username).gsub("+", "%20")
    end

    def conn
      @conn ||= Faraday.new(url: Rails.configuration.x.pda.url, headers:)
    end

    def headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end
  end
end
