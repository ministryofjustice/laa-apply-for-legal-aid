module CapitalDisregardHelper
  def mandatory_capital_disregards_list(legal_aid_application)
    mandatory_capital_disregards_names = legal_aid_application
                                          .mandatory_capital_disregards
                                          .pluck(:name).map do |key|
                                            I18n.t("providers.means.capital_disregards.mandatory.#{key}")
                                          end
    mandatory_capital_disregards_names.join("<br>").html_safe
  end

  def discretionary_capital_disregards_list(legal_aid_application)
    discretionary_capital_disregards_list = legal_aid_application
                                              .discretionary_capital_disregards
                                              .pluck(:name).map do |key|
                                                I18n.t("providers.means.capital_disregards.discretionary.#{key}")
                                              end
    discretionary_capital_disregards_list.join("<br>").html_safe
  end

  def amount_and_date_received(capital_disregard)
    "#{gds_number_to_currency(capital_disregard.amount)} on #{capital_disregard.date_received}"
  end
end
