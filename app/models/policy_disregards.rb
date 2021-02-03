class PolicyDisregards < ApplicationRecord
  belongs_to :legal_aid_application

  DISREGARDS = %i[
    england_infected_blood_support
    vaccine_damage_payments
    variant_creutzfeldt_jakob_disease
    criminal_injuries_compensation_scheme
    national_emergencies_trust
    we_love_manchester_emergency_fund
    london_emergencies_trust
  ].freeze

  def any?
    values = DISREGARDS.map { |method| __send__(method) }
    values.include?(true)
  end

  def as_json(_options = nil)
    {
      category: 'policy_disregards',
      details: build_attribute_array
    }
  end

  private

  def build_attribute_array
    DISREGARDS.map { |att| att.to_s if send(att) }.select(&:present?)
  end
end
