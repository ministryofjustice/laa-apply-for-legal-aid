class CapitalDisregard < ApplicationRecord
  belongs_to :legal_aid_application

  def incomplete?
    (name == "compensation_for_personal_harm" && payment_reason.nil?) ||
      (name == "loss_or_harm_relating_to_this_application" && payment_reason.nil?) ||
      amount.nil? ||
      account_name.nil? ||
      date_received.nil?
  end
end
