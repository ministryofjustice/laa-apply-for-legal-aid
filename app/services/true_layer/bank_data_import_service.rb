module TrueLayer
  class BankDataImportService
    prepend SimpleCommand

    def initialize(legal_aid_application:)
      @legal_aid_application = legal_aid_application
    end

    def call
      ActiveRecord::Base.transaction do
        import_bank_data
        raise ActiveRecord::Rollback if error
      end
      save_error if error
    end

    private

    attr_reader :legal_aid_application

    delegate(
      :applicant, :transaction_period_start_on, :transaction_period_finish_on,
      to: :legal_aid_application
    )

    attr_accessor :bank_provider, :bank_name, :error

    def token
      applicant.true_layer_token
    end

    def token_expires_at
      applicant.true_layer_token_expires_at
    end

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
      command = Importers::ImportTransactionsService.call(
        api_client,
        account,
        start_at: transaction_period_start_on,
        finish_at: Time.current
      )
      self.error = command.errors.first unless command.success?
    end

    def api_client
      @api_client ||= api_client_class.new(token)
    end

    def api_client_class
      Setting.mock_true_layer_data? ? ApiClientMock : ApiClient
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
