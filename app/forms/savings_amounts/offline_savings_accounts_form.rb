module SavingsAmounts
  class OfflineSavingsAccountsForm < BaseForm


    form_for SavingsAmount

    attr_accessor :offline_savings_accounts, :applicant_bank_account

    before_validation :clear_savings_amount

    validates(:offline_savings_accounts, presence: true, if: proc { |form| form.applicant_bank_account.to_s == 'true' })
    validates(:offline_savings_accounts, currency: { greater_than_or_equal_to: 0 }, allow_blank: true)
    validate :applicant_bank_account_presence

    private

    def clear_savings_amount
      offline_savings_accounts&.clear if applicant_bank_account.to_s == 'false'
    end

    def applicant_bank_account_presence
      errors.add(:applicant_bank_account, I18n.t('errors.applicant_bank_accounts.blank')) if applicant_bank_account.nil?
    end

    def attributes_to_clean
      [:offline_savings_accounts]
    end

    def exclude_from_model
      [:applicant_bank_account]
    end
  end
end
