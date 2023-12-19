module Partners
  class OfflineAccountsForm < BaseForm
    form_for SavingsAmount

    ATTRIBUTES = %i[
      partner_offline_current_accounts
      partner_offline_savings_accounts
    ].freeze

    CHECK_BOXES_ATTRIBUTES = (ATTRIBUTES.map { |attribute| "check_box_#{attribute}".to_sym } + %i[no_partner_account_selected]).freeze

    ATTRIBUTES.each do |attribute|
      check_box_attribute = "check_box_#{attribute}".to_sym
      validates attribute, presence: true, if: proc { |form| form.send(check_box_attribute).present? }
    end

    attr_accessor(*ATTRIBUTES, *CHECK_BOXES_ATTRIBUTES, :journey)

    validates(:partner_offline_current_accounts, :partner_offline_savings_accounts,
              allow_blank: true,
              currency: true)

    before_validation :empty_unchecked_values

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_no_account_and_another_checkbox_not_both_checked, unless: :draft?

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:no_partner_account_selected]
    end

    def attributes_to_clean
      ATTRIBUTES
    end

  private

    def none_and_another_checkbox_checked?
      checkbox_hash[:no_partner_account_selected].present? && checkbox_hash.except(:no_partner_account_selected).values.any?(&:present?)
    end

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def checkbox_hash
      CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
    end

    def empty_unchecked_values
      ATTRIBUTES.each do |attribute|
        check_box_attribute = "check_box_#{attribute}".to_sym
        if send(check_box_attribute).blank?
          attributes[attribute] = nil
          send("#{attribute}=", nil)
        end
      end
    end

    def validate_any_checkbox_checked
      errors.add :check_box_partner_offline_current_accounts, :blank unless any_checkbox_checked?
    end

    def validate_no_account_and_another_checkbox_not_both_checked
      errors.add :check_box_partner_offline_current_accounts, :none_and_another_option_selected if none_and_another_checkbox_checked?
    end
  end
end
