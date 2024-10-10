module Providers
  class DiscretionaryDisregardsForm < BaseForm
    form_for DiscretionaryDisregards

    SINGLE_VALUE_ATTRIBUTES = %i[
      backdated_benefits
      compensation_for_personal_harm
      criminal_injuries_compensation
      grenfell_tower_fire_victims
      london_emergencies_trust
      national_emergencies_trust
      loss_or_harm_relating_to_this_application
      victims_of_overseas_terrorism_compensation
      we_love_manchester_emergency_fund
    ].freeze
  end
end
