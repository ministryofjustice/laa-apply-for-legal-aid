module TimeHelper
  def number_of_days_ago(number_of_days, format = '%d %m %Y')
    Time.zone.now.ago(number_of_days.days).strftime(format)
  end
end
