module TrueLayerHelpers
  MOCK_DATA = {
    provider: {
      credentials_id: SecureRandom.hex,
      provider: {
        display_name: 'Lloyds Bank',
        provider_id: 'lloyds'
      }
    },
    account_holders: [{
      full_name: Faker::Name.name,
      date_of_birth: Faker::Date.backward.to_time.utc.iso8601,
      addresses: [{
        address: Faker::Address.street_address,
        city: Faker::Address.city
      }, {
        address: Faker::Address.street_address,
        city: Faker::Address.city
      }]
    }, {
      full_name: Faker::Name.name
    }],
    accounts: [{
      account_id: SecureRandom.hex,
      display_name: Faker::Bank.name,
      account_type: 'TRANSACTION',
      currency: Faker::Currency.code,
      account_number: {
        number: Faker::Number.number.to_s,
        sort_code: Faker::Number.number(digits: 6).to_s
      },
      balance: {
        current: rand(1...1_000_000.0).round(2)
      },
      transactions: [{
        transaction_id: SecureRandom.hex,
        timestamp: '2018-03-06T00:00:00',
        description: 'GOOGLE PLAY STORE',
        amount: -2.99,
        currency: 'GBP',
        transaction_type: 'DEBIT',
        merchant_name: 'Google play',
        running_balance: {
          currency: 'GBP',
          amount: 413.11
        }
      }, {
        transaction_id: SecureRandom.hex,
        timestamp: '2018-02-18T00:00:00',
        description: 'PAYPAL EBAY',
        amount: 25.25,
        currency: 'GBP',
        transaction_type: 'CREDIT',
        merchant_name: 'Ebay',
        running_balance: {}
      }]
    }, {
      account_id: SecureRandom.hex,
      display_name: Faker::Bank.name,
      account_type: 'SAVINGS',
      currency: Faker::Currency.code,
      account_number: {
        number: Faker::Number.number,
        sort_code: Faker::Number.number(digits: 6)
      },
      balance: {
        current: rand(1...1_000_000.0).round(2)
      },
      transactions: [{
        transaction_id: SecureRandom.hex
      }, {
        transaction_id: SecureRandom.hex
      }]
    }]
  }.freeze
end
