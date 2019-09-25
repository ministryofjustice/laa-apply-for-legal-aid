# Note - if using `l(date)` in an erb, format is defined in locale at en.date.formats
Date::DATE_FORMATS[:default] = '%e %B %Y'
Time::DATE_FORMATS[:datetime] = '%H:%M %d-%b-%Y'

ccms_formats = {
  ccms_date: '%Y-%m-%d',
  ccms_date_time: '%Y-%m-%dT%H:%M:%S.%3N'
}

Time::DATE_FORMATS.merge! ccms_formats
Date::DATE_FORMATS.merge! ccms_formats
