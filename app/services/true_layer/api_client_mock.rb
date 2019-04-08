module TrueLayer
  class ApiClientMock < ApiClient
    def provider
      SimpleResult.new(value: SampleData::PROVIDERS)
    end

    def account_holders
      SimpleResult.new(value: SampleData::ACCOUNT_HOLDERS)
    end

    def accounts
      SimpleResult.new(value: SampleData::ACCOUNTS)
    end

    def transactions(*)
      SimpleResult.new(value: SampleTransactionsCsvParser.call)
    end

    def account_balance(*)
      SimpleResult.new(value: SampleData::BALANCES)
    end
  end
end
