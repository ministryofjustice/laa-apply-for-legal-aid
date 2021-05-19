module Opponents
  class OpponentForm
    include BaseForm

    form_for ApplicationMeritsTask::Opponent

    attr_accessor :understands_terms_of_court_order, :understands_terms_of_court_order_details,
                  :warning_letter_sent, :warning_letter_sent_details,
                  :police_notified, :police_notified_details, :police_notified_details_true, :police_notified_details_false,
                  :bail_conditions_set, :bail_conditions_set_details, :full_name

    before_validation :clear_details, :clear_bail_details, :interpolate_police_notified_details

    def exclude_from_model
      %i[police_notified_details_true police_notified_details_false]
    end

    validates :full_name,
              presence: true,
              unless: :draft?

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
    validate :police_notified_presence

    validates :bail_conditions_set, presence: true, unless: :draft?
    validates(
      :bail_conditions_set_details,
      presence: true,
      if: proc { |form| !form.draft? && form.bail_conditions_set.to_s == 'true' }
    )

    def initialize(*args)
      super

      extrapolate_police_notified_details
    end

    private

    def police_notified_presence
      return if police_notified.blank?

      value = __send__("police_notified_details_#{police_notified}")
      return if value.present? || draft?

      translation_path = "activemodel.errors.models.opponent.attributes.police_notified_details_#{police_notified}.blank"
      errors.add("police_notified_details_#{police_notified}".to_sym, I18n.t(translation_path))
    end

    def interpolate_police_notified_details
      return unless [true, false, 'true', 'false'].include?(police_notified)

      value = __send__("police_notified_details_#{police_notified}")
      @police_notified_details = value&.empty? ? nil : value
      attributes['police_notified_details'] = @police_notified_details
    end

    def extrapolate_police_notified_details
      return unless [true, false, 'true', 'false'].include?(police_notified)
      return unless police_notified_details_expandable?

      field = "police_notified_details_#{police_notified}"
      __send__("#{field}=", police_notified_details)
      attributes[field] = police_notified_details
    end

    def clear_details
      %i[understands_terms_of_court_order warning_letter_sent].each do |attr|
        details = "#{attr}_details"
        attr_value = __send__(attr)
        __send__(details)&.clear if attr_value.to_s == 'true'
      end
    end

    def clear_bail_details
      bail_conditions_set_details&.clear if bail_conditions_set.to_s == 'false'
    end

    def police_notified_details_expandable?
      police_notified_details.present? && __send__("police_notified_details_#{police_notified}").nil?
    end
  end
end
