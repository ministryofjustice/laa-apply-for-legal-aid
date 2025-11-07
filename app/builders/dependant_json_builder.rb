class DependantJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      number:,
      name:,
      date_of_birth:,
      created_at:,
      updated_at:,
      relationship:,
      monthly_income:,
      has_income:,
      in_full_time_education:,
      has_assets_more_than_threshold:,
      assets_value:,
    }
  end
end
