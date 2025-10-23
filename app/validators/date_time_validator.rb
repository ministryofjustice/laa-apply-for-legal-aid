# this takes care of validating datetime fields before rails gets there and
# messes everything up. it should preserve the local time zone from the user input

# this goes in the model
#   validates :attribute_name, date_time: true
# or
#   validates :attribute_name, date_time: ->(field) { object.send(field).present? }
# if you want a standard presence check to be run first by the standard validator

class DateTimeValidator < ActiveModel::Validator
  def validate(record)
    options[:attributes].each do |field|
      # use the actual string and not the rails time that it has 'conveniently' converted to UTC
      raw_value = record.send("#{field}_before_type_cast")
      record[field] = if raw_value.is_a?(DateTime) || raw_value.is_a?(Time)
                        raw_value
                      elsif raw_value.is_a?(String)
                        Time.zone.parse(raw_value.to_s)
                      end
    rescue ArgumentError, TypeError
      record.errors.delete(field, :blank)
      record.errors.add(field, :unparseable)
      record[field] = raw_value
    end
  end
end
