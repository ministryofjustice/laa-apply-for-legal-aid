module SavingsAmounts
  class OfflineSavingsAccountsForm
    include BaseForm

    form_for SavingsAmount

    attr_accessor :offline_savings_accounts

    validates(:offline_savings_accounts, currency: { greater_than_or_equal_to: 0 })

    def attributes_to_clean
      [:offline_savings_accounts]
    end
  end
end
