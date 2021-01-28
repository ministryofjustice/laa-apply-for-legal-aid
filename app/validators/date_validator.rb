class DateValidator < ActiveModel::EachValidator
  DEFAULT_FORMAT = '%Y-%m-%d'.freeze
  DEFAULT_EARLIEST_DATE = '1900-01-01'.freeze

  def validate_each(record, attribute, value)
    value = parse_date(value, options[:format]) if value.is_a?(String)
    return unless valid_date(record, attribute, value)

    validate_not_in_future(record, attribute, value)
    validate_not_too_early(record, attribute, value)
  end

  private

  def parse_date(date_str, format)
    format ||= DEFAULT_FORMAT
    Time.strptime(date_str, format).in_time_zone
  rescue StandardError
    nil
  end

  def valid_date(record, attribute, value)
    message = options[:message] || :date_not_valid
    unless value.is_a?(Date)
      record.errors.add(attribute, message)
      return false
    end
    true
  end

  def validate_not_in_future(record, attribute, value)
    required = options[:not_in_the_future]
    return if required.blank?

    message = required[:message] if required.is_a?(Hash)
    message ||= :date_is_in_the_future
    record.errors.add(attribute, message) if value > Date.current
  end

  def validate_not_too_early(record, attribute, value)
    required = options[:earliest_allowed_date]
    return if required.blank?

    formatted_date = earliest_allowed_date.strftime('%d %m %Y')
    message = required[:message] if required.is_a?(Hash)
    message ||= :earliest_allowed_date
    record.errors.add(attribute, message, date: formatted_date) if value < earliest_allowed_date
  end

  def earliest_allowed_date
    date_options = options[:earliest_allowed_date]
    date = date_options.is_a?(Hash) && date_options[:date] ? date_options[:date] : DEFAULT_EARLIEST_DATE
    parse_date(date, options[:format])
  end
end
