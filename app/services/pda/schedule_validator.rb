module PDA
  class ScheduleValidator
    attr_accessor :errors

    Error = Struct.new(:attribute, :message)

    APPLICABLE_DEVOLVED_POWER_STATUSES = ["Yes - Excluding JR Proceedings", "Yes - Including JR Proceedings"].freeze
    APPLICABLE_AUTHORISATION_STATUSES = %w[APPROVED].freeze
    APPLICABLE_SCHEDULE_STATUSES = %w[Open].freeze

    def self.call(record)
      new(record).valid?
    end

    def initialize(record)
      @schedule = record
      @errors = []
    end

    def valid?
      validate_license_count
      validate_devolved_power_status
      validate_date_range
      validate_authorisation_status
      validate_schedule_status
      validate_not_cancelled

      capture_errors if errors.any?
      errors.empty?
    end

  private

    def validate_license_count
      errors << error(:license_indicator, "No license indicator") if @schedule.license_indicator.zero?
    end

    def validate_devolved_power_status
      errors << error(:devolved_power_status, "Devolved power status incorrect") unless APPLICABLE_DEVOLVED_POWER_STATUSES.include?(@schedule.devolved_power_status)
    end

    def validate_date_range
      errors << error(:start_date, "Schedule start date is in the future") if @schedule.start_date.future?
      errors << error(:end_date, "Schedule end date is in the past: #{@schedule.end_date}") if @schedule.end_date <= Date.current
    end

    def validate_authorisation_status
      errors << error(:authorisation_status, "Authorisation status is not approved") unless APPLICABLE_AUTHORISATION_STATUSES.include?(@schedule.authorisation_status)
    end

    def validate_schedule_status
      errors << error(:status, "Schedule status is not open") unless APPLICABLE_SCHEDULE_STATUSES.include?(@schedule.status)
    end

    def validate_not_cancelled
      errors << error(:cancelled, "Schedule is cancelled") if @schedule.cancelled?
    end

    def error(*)
      Error.new(*)
    end

    def capture_errors
      Rails.logger.info(errors.map(&:message).join("\n"))
      AlertManager.capture_message("Schedule is invalid (id: #{@schedule.id}) - #{errors.map(&:message).join(', ')}")
    end
  end
end
