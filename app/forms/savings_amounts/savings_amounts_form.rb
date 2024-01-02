module SavingsAmounts
  class SavingsAmountsForm < BaseForm
    form_for SavingsAmount

    ATTRIBUTES = %i[
      cash
      other_person_account
      national_savings
      plc_shares
      peps_unit_trusts_capital_bonds_gov_stocks
      life_assurance_endowment_policy
    ].freeze

    CHECK_BOXES_ATTRIBUTES = (ATTRIBUTES.map { |attribute| :"check_box_#{attribute}" } + %i[none_selected]).freeze

    attr_accessor(*ATTRIBUTES, *CHECK_BOXES_ATTRIBUTES, :journey)

    ATTRIBUTES.each do |attribute|
      check_box_attribute = :"check_box_#{attribute}"
      validates attribute, presence_partner_optional: { partner_labels: :has_partner_with_no_contrary_interest? }, if: proc { |form| form.send(check_box_attribute).present? }
    end

    validates(*ATTRIBUTES, allow_blank: true, currency: { greater_than_or_equal_to: 0, partner_labels: :has_partner_with_no_contrary_interest? })

    before_validation :empty_unchecked_values

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_none_and_another_checkbox_not_both_checked, unless: :draft?

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:none_selected]
    end

    def attributes_to_clean
      ATTRIBUTES
    end

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

  private

    def none_and_another_checkbox_checked?
      checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
    end

    def checkbox_hash
      CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
    end

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def empty_unchecked_values
      ATTRIBUTES.each do |attribute|
        check_box_attribute = :"check_box_#{attribute}"
        if send(check_box_attribute).blank?
          attributes[attribute] = nil
          send("#{attribute}=", nil)
        end
      end
    end

    def base_checkbox
      CHECK_BOXES_ATTRIBUTES.first
    end

    def validate_any_checkbox_checked
      errors.add base_checkbox.to_sym, error_message_for_none_selected unless any_checkbox_checked?
    end

    def validate_none_and_another_checkbox_not_both_checked
      errors.add base_checkbox.to_sym, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.savings_amount.attributes.base.#{journey}.#{error_key('none_selected')}")
    end

    def error_message_for_none_and_another_option_selected
      I18n.t("activemodel.errors.models.savings_amount.attributes.base.none_and_another_option_selected")
    end
  end
end
