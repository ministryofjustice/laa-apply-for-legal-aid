module TrueLayer
  class BankDataImportService
    def initialize(applicant:, token:)
      @applicant = applicant
      @token = token
    end

    def call
      return unless bank_provider

      import_bank_accounts
      import_account_holders
      import_transactions
    end

    private

    attr_reader :applicant, :token

    def bank_provider
      @bank_provider ||= Importers::ImportProviderService.new(api_client, applicant, token).call
    end

    def import_bank_accounts
      Importers::ImportAccountsService.new(api_client, bank_provider).call
      bank_provider.bank_accounts.each do |account|
        Importers::ImportAccountBalanceService.new(api_client, account).call
      end
    end

    def import_account_holders
      Importers::ImportAccountHoldersService.new(api_client, bank_provider).call
    end

    def import_transactions
      bank_provider.bank_accounts.each do |account|
        Importers::ImportTransactionsService.new(api_client, account).call
      end
    end

    def api_client
      @api_client ||= ApiClient.new(token)
    end
  end
end
