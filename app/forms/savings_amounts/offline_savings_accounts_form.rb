module SavingsAmounts
  class OfflineSavingsAccountsForm
    include BaseForm

    form_for SavingsAmount

    attr_accessor :offline_savings_accounts
    attr_accessor :applicant_bank_account

    validates :offline_savings_accounts,
              currency: { greater_than_or_equal_to: 0 },
              if: proc { |form| form.applicant_bank_account.to_s == 'true' }
    validate :applicant_bank_account_presence

    def applicant_bank_account_presence
      errors.add(:applicant_bank_account, I18n.t('errors.applicant_bank_accounts.blank')) if applicant_bank_account.nil?
    end

    def attributes_to_clean
      [:offline_savings_accounts]
    end
  end
end
