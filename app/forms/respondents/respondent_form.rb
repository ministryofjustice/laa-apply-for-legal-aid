module Respondents
  class RespondentForm
    include BaseForm

    form_for Respondent

    attr_accessor :understands_terms_of_court_order, :understands_terms_of_court_order_details,
                  :warning_letter_sent, :warning_letter_sent_details,
                  :police_notified, :police_notified_details,
                  :bail_conditions_set, :bail_conditions_set_details

    validates :understands_terms_of_court_order, presence: true, unless: :draft?
    validates(
      :understands_terms_of_court_order_details,
      presence: true,
      if: proc { |form| !form.draft? && form.understands_terms_of_court_order.to_s == 'false' }
    )

    validates :warning_letter_sent, presence: true, unless: :draft?
    validates(
      :warning_letter_sent_details,
      presence: true,
      if: proc { |form| !form.draft? && form.warning_letter_sent.to_s == 'false' }
    )

    validates :police_notified, presence: true, unless: :draft?
    validates(
      :police_notified_details,
      presence: true,
      if: proc { |form| !form.draft? && form.police_notified.to_s == 'false' }
    )

    validates :bail_conditions_set, :bail_conditions_set_details, presence: true, unless: :draft?
  end
end
