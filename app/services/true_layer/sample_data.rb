module TrueLayer
  module SampleData
    PROVIDERS = [
      {
        credentials_id: 'ihYXzOOCbi5MpjYIM3LSnfje4znMKo43qKK01+wGbKA=',
        client_id: 'client_id',
        provider: {
          display_name: 'Mock',
          provider_id: 'sample'
        }
      }
    ].freeze

    ACCOUNT_HOLDERS = [
      {
        full_name: 'John Doe',
        addresses: [
          {
            address: '1 Market Street',
            city: 'San Francisco',
            zip: '94103',
            country: 'USA'
          }
        ]
      }
    ].freeze

    ACCOUNTS = [
      {
        account_id: 'ce83a04b9051a61add6139daa8f7578b',
        display_name: 'Current Account',
        account_type: 'TRANSACTION',
        currency: 'GBP',
        account_number: {
          number: '10000000',
          sort_code: '01-21-31'
        }
      }
    ].freeze

    BALANCES = [{ current: 2000.0 }].freeze
  end
end
