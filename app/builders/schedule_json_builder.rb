class ScheduleJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      office_id:,
      area_of_law:,
      category_of_law:,
      authorisation_status:,
      status:,
      start_date:,
      end_date:,
      cancelled:,
      license_indicator:,
      devolved_power_status:,
      created_at:,
      updated_at:,
    }
  end
end
