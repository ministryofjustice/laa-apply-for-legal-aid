module PDA
  class ScheduleValidator
    attr_accessor :errors

    Error = Struct.new(:attribute, :message)

    APPLICABLE_DEVOLVED_POWER_STATUSES = ["Yes - Excluding JR Proceedings", "Yes - Including JR Proceedings"].freeze

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

      capture_errors if errors
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
      errors << error(:end_date, "Schedule end date is in the past") if @schedule.end_date >= Date.current
    end

    def error(*)
      Error.new(*)
    end

    def capture_errors
      AlertManager.capture_message("Schedule is invalid (id: #{@schedule.id}) - #{errors.map(&:message).join(', ')}")
    end
  end
end
