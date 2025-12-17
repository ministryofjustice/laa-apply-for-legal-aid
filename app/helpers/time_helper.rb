module TimeHelper
  def number_of_days_ago(number_of_days, format = "%d %_m %Y")
    Time.zone.now.ago(number_of_days.days).strftime(format)
  end

  def gds_human_time(time)
    if time.min.zero?
      time.strftime("%-l%P")
    else
      time.strftime("%-l:%M%P")
    end
  end
end
