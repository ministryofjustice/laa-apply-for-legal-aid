module PolicyDisregardsHelper
  include CheckAnswersHelper

  ATTRIBUTES = %i[
    england_infected_blood_support
    vaccine_damage_payments
    variant_creutzfeldt_jakob_disease
    criminal_injuries_compensation_scheme
    national_emergencies_trust
    we_love_manchester_emergency_fund
    london_emergencies_trust
  ].freeze

  def policy_disregards_hash(policy_disregards)
    items = policy_disregards_as_array(policy_disregards)
    items&.compact!
    return nil if items.blank?

    {
      items: items
    }
  end

  def policy_disregards_as_array(policy_disregards)
    ATTRIBUTES&.map do |attribute|
      send(attribute, policy_disregards) if policy_disregards.send("#{attribute}?")
    end
  end

  def england_infected_blood_support(policy_disregards)
    build_ostruct(
      t('england_infected_blood_support', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.england_infected_blood_support
    )
  end

  def vaccine_damage_payments(policy_disregards)
    build_ostruct(
      t('vaccine_damage_payments', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.vaccine_damage_payments
    )
  end

  def variant_creutzfeldt_jakob_disease(policy_disregards)
    build_ostruct(
      t('variant_creutzfeldt_jakob_disease', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.variant_creutzfeldt_jakob_disease
    )
  end

  def criminal_injuries_compensation_scheme(policy_disregards)
    build_ostruct(
      t('criminal_injuries_compensation_scheme', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.criminal_injuries_compensation_scheme
    )
  end

  def national_emergencies_trust(policy_disregards)
    build_ostruct(
      t('national_emergencies_trust', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.national_emergencies_trust
    )
  end

  def we_love_manchester_emergency_fund(policy_disregards)
    build_ostruct(
      t('we_love_manchester_emergency_fund', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.we_love_manchester_emergency_fund
    )
  end

  def london_emergencies_trust(policy_disregards)
    build_ostruct(
      t('london_emergencies_trust', scope: 'shared.forms.policy_disregards.form.providers.policy_disregards'),
      policy_disregards.london_emergencies_trust
    )
  end
end
