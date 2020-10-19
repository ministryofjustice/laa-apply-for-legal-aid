module TimeHelper
  def number_of_months_ago(number_of_months, format = '%d %m %Y')
    Time.zone.now.ago(number_of_months.months).strftime(format)
  end
end
