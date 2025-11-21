class OtherAssetsDeclarationJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      second_home_value:,
      second_home_mortgage:,
      second_home_percentage:,
      timeshare_property_value:,
      land_value:,
      valuable_items_value:,
      inherited_assets_value:,
      money_owed_value:,
      trust_value:,
      created_at:,
      updated_at:,
      none_selected:,
    }
  end
end
