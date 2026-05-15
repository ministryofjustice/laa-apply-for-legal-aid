class OfficeJsonBuilder < BaseJsonBuilder
  def attribute_hash
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
