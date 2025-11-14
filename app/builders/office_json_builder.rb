class OfficeJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      created_at:,
      updated_at:,
      ccms_id:,
      code:,
      firm_id:,
      schedules: schedules.map { |s| ScheduleJsonBuilder.build(s).as_json },
    }
  end
end
