# The below hotfix overrides the rails 7 removal of to_s
# https://guides.rubyonrails.org/7_0_release_notes.html#active-support-deprecations
# and allows our default format to be applied rather than having
# to find each date and manually add `.to_fs` to the end of it
require "date"

class Date
  alias_method :to_s, :to_fs
end

# Note - if using `l(date)` in an erb, format is defined in locale at en.date.formats
Date::DATE_FORMATS[:default] = "%e %B %Y"
Time::DATE_FORMATS[:datetime] = "%H:%M %d-%b-%Y"

# This is the format returned by the moj datepicker component (no padding on day and month, e.g. 1/1/2001)
Date::DATE_FORMATS[:date_picker] = "%-d/%-m/%Y"
Date::DATE_FORMATS[:date_picker_parse_format] = "%d/%m/%Y"

ccms_formats = {
  ccms_date: "%Y-%m-%d",
  ccms_date_time: "%Y-%m-%dT%H:%M:%S.%3N",
}

Time::DATE_FORMATS.merge! ccms_formats
Date::DATE_FORMATS.merge! ccms_formats
