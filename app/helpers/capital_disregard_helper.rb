module CapitalDisregardHelper
  def mandatory_capital_disregards_list(legal_aid_application)
    capital_disregard_names(legal_aid_application.mandatory_capital_disregards).join("<br>").html_safe
  end

  def mandatory_capital_disregards_detailed_list(legal_aid_application)
    legal_aid_application.mandatory_capital_disregards.map { |capital_disregard|
      capital_disregards_detail_for(capital_disregard)
    }.join("<br><br>").html_safe
  end

  def discretionary_capital_disregards_list(legal_aid_application)
    capital_disregard_names(legal_aid_application.discretionary_capital_disregards).join("<br>").html_safe
  end

  def discretionary_capital_disregards_detailed_list(legal_aid_application)
    legal_aid_application.discretionary_capital_disregards.map { |capital_disregard|
      capital_disregards_detail_for(capital_disregard)
    }.join("<br><br>").html_safe
  end

  # NOTE: single digit days get extra left padding so we strip for consistent spacing
  def amount_and_date_received(capital_disregard)
    "#{gds_number_to_currency(capital_disregard.amount)} on #{capital_disregard.date_received.to_s.strip}"
  end

private

  def capital_disregard_names(capital_disregard_association)
    capital_disregard_association
      .map do |capital_disregard|
        name_t(capital_disregard)
      end
  end

  def capital_disregards_detail_for(capital_disregard)
    [
      name_t(capital_disregard),
      payment_reason_for(capital_disregard),
      amount_and_date_received(capital_disregard),
      held_in(capital_disregard.account_name),
    ].compact.join("<br>").html_safe
  end

  def payment_reason_for(capital_disregard)
    t("providers.means.capital_disregards.payment_reason_for", reason: capital_disregard.payment_reason) if capital_disregard.payment_reason.present?
  end

  def name_t(capital_disregard)
    type = capital_disregard.mandatory? ? "mandatory" : "discretionary"

    t("providers.means.capital_disregards.#{type}.#{capital_disregard.name}")
  end

  def held_in(account_name)
    t("providers.means.capital_disregards.held_in", account_name:)
  end
end
