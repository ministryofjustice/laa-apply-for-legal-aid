module TrueLayer
  class BankAccountIdentity
    def initialize(api_client)
      @api_client = api_client
    end

    def provider
      @provider ||= api_client.api_client.fetch_resource('/data/v1/me').first
    end

    def account_holders
      @account_holders || api_client.fetch_resource('/data/v1/info')
    end

    def accounts
      @accounts ||= api_client.fetch_resource('/data/v1/accounts')
    end

    def transactions
      @transactions ||= account_ids.each_with_object({}) do |account_id, hash|
        hash[account_id] = account_transactions(account_id)
      end
    end

    def account_balances
      @account_balances ||= account_ids.each_with_object({}) do |account_id, hash|
        hash[account_id] = account_balance(account_id)
      end
    end

    private

    attr_reader :api_client

    def account_ids
      @account_ids || accounts.pluck(:account_id)
    end

    def account_transactions(account_id)
      params = {
        from: transacions_date_from.utc.iso8601,
        to: transacions_date_to.utc.iso8601
      }
      api_client.fetch_resource("/data/v1/accounts/#{account_id}/transactions?#{params.to_query}")
    end

    def account_balance(account_id)
      api_client.fetch_resource("/data/v1/accounts/#{account_id}/balance").first
    end

    def transacions_date_to
      @transacions_date_to ||= Time.now
    end

    def transacions_date_from
      @transacions_date_from ||= (date_to - 3.months - 1.day).beginning_of_day
    end
  end
end
