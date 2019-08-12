module Respondents
  class RespondentForm
    include BaseForm

    form_for Respondent

    attr_accessor :understands_terms_of_court_order, :understands_terms_of_court_order_details,
                  :warning_letter_sent, :warning_letter_sent_details,
                  :police_notified, :police_notified_details,
                  :bail_conditions_set, :bail_conditions_set_details

<<<<<<< HEAD
    before_validation :clear_fields
=======
    before_validation :clear_details, :clear_bail_details
>>>>>>> bdb7c5f2... Update views and forms

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

    validates :bail_conditions_set, presence: true, unless: :draft?
    validates(
      :bail_conditions_set_details,
      presence: true,
      if: proc { |form| !form.draft? && form.bail_conditions_set.to_s == 'true' }
    )

    private

<<<<<<< HEAD
    def clear_fields
=======
    def clear_details
>>>>>>> bdb7c5f2... Update views and forms
      %i[
        understands_terms_of_court_order
        warning_letter_sent
        police_notified
      ].each do |attr|
<<<<<<< HEAD
        attribute_call = method("#{attr}_details").call
        attribute_call&.clear unless ActiveModel::Type::Boolean.new.cast(attr.to_s)
      end
      # bail_conditions_set_details&.clear
=======
        details = "#{attr}_details".to_sym
        attr_value = __send__(attr)
        __send__(details)&.clear if attr_value.to_s == 'true'
      end
    end

    def clear_bail_details
      bail_conditions_set_details&.clear if bail_conditions_set.to_s == 'false'
>>>>>>> bdb7c5f2... Update views and forms
    end
  end
end
