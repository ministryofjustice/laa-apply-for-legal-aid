module Editing
  class CapitalAndAssetsCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      legal_aid_application.update!(
        # "own_home" and "property_details" pages
        own_home: nil,
        property_value: nil,
        outstanding_mortgage_amount: nil,
        shared_ownership: nil,
        percentage_home: nil,

        # vehicles
        own_vehicle: nil,

        # "restrictions"
        has_restrictions: nil,
        restrictions_details: nil,
      )

      # "vehicle_details"
      legal_aid_application.vehicles.each(&:destroy!)

      # "offline_accounts" and "savings_and_investments" pages
      legal_aid_application.savings_amount&.destroy!

      # "other_assets" => capital_and_assets_sidebar_items,
      legal_aid_application.other_assets_declaration&.destroy!

      # "disregarded_payments" (aka mandatory disregards), "'payments_to_review" (aka discretionary disregards) and "capital_disregards/add_details" pages
      legal_aid_application.capital_disregards.each(&:destroy!)
    end

  private

    attr_reader :legal_aid_application
  end
end
