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

    validate :any_checkbox_checked_or_draft

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:no_partner_account_selected]
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
      errors.add :check_box_partner_offline_current_accounts, :blank unless any_checkbox_checked? || draft?
    end
  end
end
