RSpec::Matchers.define :have_been_in_the_past do
  match do |actual_time|
    @time_now = Time.current
    actual_time < @time_now
  end

  failure_message do |actual_time|
    "Expected actual_time (#{actual_time.to_f}) to be earlier than now (#{@time_now.to_f})"
  end
end
