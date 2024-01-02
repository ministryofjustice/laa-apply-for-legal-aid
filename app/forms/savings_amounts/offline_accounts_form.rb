module SavingsAmounts
  class OfflineAccountsForm < BaseForm
    form_for SavingsAmount

    ATTRIBUTES = %i[
      offline_current_accounts
      offline_savings_accounts
      partner_offline_current_accounts
      partner_offline_savings_accounts
      joint_offline_current_accounts
      joint_offline_savings_accounts
    ].freeze

    CHECK_BOXES_ATTRIBUTES = %i[
      check_box_offline_current_accounts
      check_box_offline_savings_accounts
      check_box_partner_offline_current_accounts
      check_box_partner_offline_savings_accounts
      check_box_joint_offline_current_accounts
      check_box_joint_offline_savings_accounts
      no_account_selected
    ].freeze

    ATTRIBUTES.each do |attribute|
      check_box_attribute = :"check_box_#{attribute}"
      validates attribute, presence: true, if: proc { |form| form.send(check_box_attribute).present? }
    end

    attr_accessor(*ATTRIBUTES, *CHECK_BOXES_ATTRIBUTES, :journey)

    validates(:offline_current_accounts, :offline_savings_accounts,
              :partner_offline_current_accounts, :partner_offline_savings_accounts,
              :joint_offline_current_accounts, :joint_offline_savings_accounts,
              allow_blank: true,
              currency: true)

    before_validation :empty_unchecked_values

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_no_account_and_another_checkbox_not_both_checked, unless: :draft?

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:no_account_selected]
    end

    def attributes_to_clean
      ATTRIBUTES
    end

  private

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def no_account_and_another_checkbox_checked?
      checkbox_hash[:no_account_selected].present? && checkbox_hash.except(:no_account_selected).values.any?(&:present?)
    end

    def checkbox_hash
      CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
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

    def validate_no_account_and_another_checkbox_not_both_checked
      errors.add :check_box_offline_current_accounts, error_message_for_no_account_and_another_option_selected if no_account_and_another_checkbox_checked?
    end

    def validate_any_checkbox_checked
      errors.add :check_box_offline_current_accounts, error_message_for_no_account_selected unless any_checkbox_checked?
    end

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application&.applicant&.has_partner_with_no_contrary_interest?
    end

    def error_message_for_no_account_selected
      I18n.t("activemodel.errors.models.savings_amount.attributes.base.providers.#{error_key('no_account_selected')}")
    end

    def error_message_for_no_account_and_another_option_selected
      I18n.t("activemodel.errors.models.savings_amount.attributes.base.providers.no_account_and_another_option_selected")
    end
  end
end
