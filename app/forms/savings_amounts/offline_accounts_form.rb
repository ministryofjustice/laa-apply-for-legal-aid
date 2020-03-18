module SavingsAmounts
  class OfflineAccountsForm
    include BaseForm

    form_for SavingsAmount

    ATTRIBUTES = %i[
      offline_current_accounts
      offline_savings_accounts
    ].freeze

    CHECK_BOXES_ATTRIBUTES = (ATTRIBUTES.map { |attribute| "check_box_#{attribute}".to_sym } + %i[no_account_selected]).freeze

    ATTRIBUTES.each do |attribute|
      check_box_attribute = "check_box_#{attribute}".to_sym
      validates attribute, presence: true, if: proc { |form| form.send(check_box_attribute).present? }
    end

    attr_accessor(*ATTRIBUTES)
    attr_accessor(*CHECK_BOXES_ATTRIBUTES)
    attr_accessor :journey

    validates(:offline_current_accounts, :offline_savings_accounts, allow_blank: true, currency: true)

    before_validation :empty_unchecked_values

    validate :any_checkbox_checked_or_draft

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:no_account_selected]
    end

    def attributes_to_clean
      ATTRIBUTES
    end

    def any_checkbox_checked?
      CHECK_BOXES_ATTRIBUTES.map { |attribute| __send__(attribute) }.any?(&:present?)
    end

    private

    def empty_unchecked_values
      ATTRIBUTES.each do |attribute|
        check_box_attribute = "check_box_#{attribute}".to_sym
        if send(check_box_attribute).blank?
          attributes[attribute] = nil
          send("#{attribute}=", nil)
        end
      end
    end

    def any_checkbox_checked_or_draft
      errors.add :base, error_message_for_no_account_selected unless any_checkbox_checked? || draft?
    end

    def error_message_for_no_account_selected
      I18n.t('activemodel.errors.models.savings_amount.attributes.base.providers.no_account_selected')
    end
  end
end
