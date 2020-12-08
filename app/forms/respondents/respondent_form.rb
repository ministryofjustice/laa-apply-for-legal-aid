module Respondents
  class RespondentForm
    include BaseForm

    form_for Respondent

    attr_accessor :understands_terms_of_court_order, :understands_terms_of_court_order_details,
                  :warning_letter_sent, :warning_letter_sent_details,
                  :police_notified, :police_notified_details,
                  :bail_conditions_set, :bail_conditions_set_details, :full_name

    before_validation :clear_details, :clear_bail_details

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
      if: proc { |form| !form.draft? && (%w[true false].include? form.police_notified.to_s) }
    )

    validates :bail_conditions_set, presence: true, unless: :draft?
    validates(
      :bail_conditions_set_details,
      presence: true,
      if: proc { |form| !form.draft? && form.bail_conditions_set.to_s == 'true' }
    )

    private

    def clear_details
      %i[understands_terms_of_court_order warning_letter_sent].each do |attr|
        details = "#{attr}_details".to_sym
        attr_value = __send__(attr)
        __send__(details)&.clear if attr_value.to_s == 'true'
      end
    end

    def clear_bail_details
      bail_conditions_set_details&.clear if bail_conditions_set.to_s == 'false'
    end
  end
end
