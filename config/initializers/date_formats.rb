# The below hotfix is taken from https://stackoverflow.com/a/71328079
# Overrides the rails 7 removal of to_s and allows our default
# format to be applied rather than having to find each date
# and manually add `.to_fs` to the end of it
require "date"

class Date
  def to_s(format = :default)
    if (formatter = DATE_FORMATS[format])
      if formatter.respond_to?(:call)
        formatter.call(self).to_s
      else
        strftime(formatter)
      end
    else
      to_default_s
    end
  end
end

# Note - if using `l(date)` in an erb, format is defined in locale at en.date.formats
Date::DATE_FORMATS[:default] = "%e %B %Y"
Time::DATE_FORMATS[:datetime] = "%H:%M %d-%b-%Y"

ccms_formats = {
  ccms_date: "%Y-%m-%d",
  ccms_date_time: "%Y-%m-%dT%H:%M:%S.%3N",
}

Time::DATE_FORMATS.merge! ccms_formats
Date::DATE_FORMATS.merge! ccms_formats
