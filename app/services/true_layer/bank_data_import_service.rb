module TrueLayer
  class BankDataImportService
    prepend SimpleCommand

    def initialize(applicant:, token:, token_expires_at:)
      @applicant = applicant
      @token = token
      @token_expires_at = token_expires_at
    end

    def call
      ActiveRecord::Base.transaction do
        import_bank_data
        raise ActiveRecord::Rollback if error
      end
      save_error if error
    end

    private

    attr_accessor :applicant, :token, :token_expires_at, :bank_provider, :bank_name, :error

    def import_bank_data
      import_bank_provider
      import_account_holders unless error
      import_bank_accounts unless error
      import_bank_account_balances unless error
      import_transactions unless error
    end

    def import_bank_provider
      command = Importers::ImportProviderService.call(
        api_client: api_client,
        applicant: applicant,
        token: token,
        token_expires_at: token_expires_at
      )
      if command.success?
        self.bank_provider = command.result
        self.bank_name = bank_provider.name
      else
        self.error = command.errors.first
      end
    end

    def import_account_holders
      command = Importers::ImportAccountHoldersService.call(api_client, bank_provider)
      self.error = command.errors.first unless command.success?
    end

    def import_bank_accounts
      command = Importers::ImportAccountsService.call(api_client, bank_provider)
      self.error = command.errors.first unless command.success?
    end

    def import_bank_account_balances
      bank_provider.bank_accounts.each do |account|
        import_account_balance(account) unless error
      end
    end

    def import_transactions
      bank_provider.bank_accounts.each do |account|
        import_account_transactions(account) unless error
      end
    end

    def import_account_balance(account)
      command = Importers::ImportAccountBalanceService.call(api_client, account)
      self.error = command.errors.first unless command.success?
    end

    def import_account_transactions(account)
      command = Importers::ImportTransactionsService.call(api_client, account)
      self.error = command.errors.first unless command.success?
    end

    def api_client
      @api_client ||= ApiClient.new(token)
    end

    def save_error
      BankError.create!(
        applicant: applicant,
        bank_name: bank_name,
        error: error
      )
      errors.add(:bank_data_import, error)
    end
  end
end
