module TrueLayer
  module SampleData # rubocop:disable Metrics/ModuleLength
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

    TRANSACTIONS = [
      {
        transaction_id: 'd325161c2c997d9b1925974d9b9d1f5a',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-09-27T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c559da3d0632828c24f95af3b4d95df1',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-09-28T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '41d46006b7fdad921e6714e343f088f2',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -8.48,
        timestamp: '2018-09-28T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a4942e612476fcd89d3ab2a6a648d17a',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-09-29T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '387c4a5510939fa37f523ffec19dc768',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-09-29T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '31e38aa8ac6f36d86c5112a78797e723',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-09-29T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8cd7b48bde4cdb2da33e9b8824847fc6',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-09-29T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9e255f75d3a97609b50dc6031e0c080d',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -15.8,
        timestamp: '2018-09-29T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9326d8bf89e279851d7f817342528637',
        description: 'Cash RB Scot Oct01 Tesco Killburn',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-10-04T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '552569a75adf9f54bdcbe1a5a7084f55',
        description: 'Creation.co.uk',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bc8c404fb33f0f3d8b5031ef9e7f1aa3',
        description: 'DVLA-REGNUM',
        currency: 'GBP',
        amount: -19.25,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1691d2f13b5e6419518a38aacbc6bc37',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ea97ad89f99a38de2946acb3f3f76548',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 108.24,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '0b8935d1e11abfcf4b94ed03edefd99c',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -67.92,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '21776ecf98a2268253ac38fd4ab22918',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '01e086ccdb4ab45e5f1d623bde861598',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '70a9a66f7e2c68a969e9caa43fb3a52d',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f8f7d2b539df43d0cb2b1fd8c335718f',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-10-02T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c3deaea30957a1b422b3e940271bca16',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-10-03T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9116cec8e5361462dd0699f00a62b30b',
        description: 'Sky digital reversal of 03-10',
        currency: 'GBP',
        amount: 56.79,
        timestamp: '2018-10-03T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'bb1ee58951004372862ac11a3f65a0d9',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.55,
        timestamp: '2018-10-06T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '00534d2f15712f8ddb19c9dc3fb0f9fa',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-07T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0114b4a5341a03f9fa8a3ef9973b1652',
        description: 'Cash Notemachine ',
        currency: 'GBP',
        amount: -30.0,
        timestamp: '2018-10-07T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f65a8d9e0330ec21a78189368819379f',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 116.4,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '929d1bdec1c1f708d3911eed45c333c3',
        description: 'Cash in HSBC 09Oct',
        currency: 'GBP',
        amount: 60.0,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'df6759882536d3b74f99477b7761a6f5',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '812f1f03f8d00d62cf591f57f8662c21',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e067fb9c885137d29a5cd92b9b0711b2',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a92a9b6e30d76d494b7a2865e962a3e2',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cfb7d62b1be9351d967ad9172767f3a9',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f7bc27e7d5cde26cbe55a152b8fcb0a6',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-10-09T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '13d97152eddbdd20da56c97c4411b86a',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-10-11T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2acca1297e350bcf5dc6ddeadfa7c3ac',
        description: 'Sky digital reversal of 11-10',
        currency: 'GBP',
        amount: 56.79,
        timestamp: '2018-10-11T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c669caf7d173d456ab4577b7f0003fee',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '51a76c38395ebfdb2fe2c423a9a982a7',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '69ee4c4c73157f6233e4ced57c2b7055',
        description: 'Cash RB Scot Oct13 Tesco Killburn',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1e88ad84ef1ea37a071ac0d03966f683',
        description: 'Cash Barclay Asda Oct13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ecf3b4de2b59d75c8c2e33175462a03e',
        description: 'Cash BNKM Cooperative Oct13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8cbeb9cd87dfaaaaaac2c2bb2a532390',
        description: 'Cash BNKM Cooperative Oct14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '74dd77c90d5010916489601a6769d419',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 136.31,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '2976afbb2761fcd6eca5cd06f7fff863',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f6e09a917b2232d819c73c1a90709b3d',
        description: 'Cash in HSBC 16Oct',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c1f5344ebd9a0eadf41c7353ca361245',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd9c57bb677e38d46287bdac94893df2c',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cdc78a948fd6e8786889f1bbf1510d73',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6bf8a37d87f4f224718b3dcc70954fe2',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-10-14T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9db85b4fae89500e5eaf1b120033380a',
        description: 'Cash in HSBC 17Oct',
        currency: 'GBP',
        amount: 250.0,
        timestamp: '2018-10-17T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f86aadb0339fd4d75a5ce2234574c50f',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-10-17T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0a8583df08d1fbffe0172fd8b3b461be',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-17T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '715138ea5f9257152b0892796e5c0349',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -8.0,
        timestamp: '2018-10-17T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a247efd3b928d5910a5077cc90f8c8ab',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-10-17T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '523f8c53b29022d1445d193bced79540',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-10-18T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '294eae60578b8e49a42c09fe251c409a',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-10-18T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1fc1dbd95d53029fae9b3f602830144e',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-18T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c87c1e439784e7735fca4dc7723001e8',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-18T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '724e73de9801c3204c186cff923b68f8',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-18T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4db134533905918df8485cd60d139b03',
        description: 'Cash Natwide Oct19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-19T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '075afc8961cd33861323db1b01595dc0',
        description: 'Poundstretcher',
        currency: 'GBP',
        amount: -29.97,
        timestamp: '2018-10-19T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '666cd8117df6403d8dbdd65168bd65a1',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -14.99,
        timestamp: '2018-10-19T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f543acfbe6eca730b40ef2c7ce96686f',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -11.99,
        timestamp: '2018-10-19T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7a0bf83cab951998600e15c9c3273da2',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-19T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c4c9efd8a3b947663ac782960bd4b194',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-20T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '80f10a10b761344be1995b6703f05ce5',
        description: 'Cash bnkm Oct20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-20T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '21e24432d83e266936e1adc2b09f08dc',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-20T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c5b337b296495cbbca5afbccaf67b17a',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-10-20T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '26513150ab61569ffd1336202ed2736d',
        description: 'Cash RB SCOT Oct21',
        currency: 'GBP',
        amount: -250.0,
        timestamp: '2018-10-21T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'df2824ed5cd0819b8d4f7a054602e55b',
        description: 'Cash Barclay Asda Oct21',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-10-21T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a98bf8df128edf048cdf872b71475d83',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '983b8e95cb9ae64d22c7048868e0838b',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '159b845f5646c82c585ddf3a8ac080fd',
        description: 'Cash bnkm Oct23',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8404260f16c59472b97d5fd1076faf2f',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6140a328bd9a1e5fc34ea647f6c02bb4',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3599cfeb09fe297305efd56f15453a1b',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e5cc2c674f11103554ddd25462b5c93a',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7d1e8829190aba3f88ede88760c3ece9',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7352f24875893cdb9cbd39afdb16f00c',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-10-23T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f9b15387527fc8cc246abee00e694560',
        description: 'Paypal ',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-10-24T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cc2d30ba4787389d05aa841be9b49bfb',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-10-24T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd061326c9fdefea6e5687f8fe0e2cf9c',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-10-24T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '876b051fbfe88663229bce3e8f00784b',
        description: 'Wickes',
        currency: 'GBP',
        amount: -28.98,
        timestamp: '2018-10-24T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6bf8ef074f3d40082a11c67f33bc6dd3',
        description: 'Cash RB Scot Oct25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-25T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'fa4aeb1b4ce5e7120d6b00441a8d5771',
        description: 'Petrol station M25',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-25T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '895cc2f4438ed5966bc35e130bc922a5',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -28.23,
        timestamp: '2018-10-25T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'aa7a15cce90dc764b53f5e95e9140926',
        description: 'Finchley services',
        currency: 'GBP',
        amount: -20.86,
        timestamp: '2018-10-25T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '716405cf1c5cfd68e73eb121b432efc6',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-26T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f8b02af0b74e5cc3df4a4b78e9817bfd',
        description: 'White Swan',
        currency: 'GBP',
        amount: -7.79,
        timestamp: '2018-10-26T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0483270d70c2af3287b39396565fed52',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-27T00:00:00.000+01:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f176b06d6ea04d4333b0fcc6fe889e8c',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-27T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd66328cced2fe4e374e8e8e1a5fa9ef2',
        description: 'Masons arms ',
        currency: 'GBP',
        amount: -12.98,
        timestamp: '2018-10-27T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bdb9252c8eb8317976389bd5be05acbd',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-10-27T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6587f0ea31034b59cbc1092b3fe306e3',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-28T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e38893330b0442ce9e04c9a78289042e',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -8.48,
        timestamp: '2018-10-28T00:00:00.000+01:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9d47707d47d4c18646fe9200d9b7d287',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-29T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'b26457620f0171f86333f402379f08b8',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-10-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4d15912e44bfb0b4535aac2548555e8f',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-10-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ebd2cb3c1381d5cad98924c9854ff0b7',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'dfb2259f7be38932443967d090865fc1',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -15.8,
        timestamp: '2018-10-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6c7b80dd315713c45c2aa799c4f01c1b',
        description: 'Creation.co.uk',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1db8bd821655cb96f94bbba9d2515c50',
        description: 'DVLA-REGNUM',
        currency: 'GBP',
        amount: -19.25,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7dfea18b78c2bfe9a3d6a2112ac035fb',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '93dea2ec27b642fa028ba36acaa8e531',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 108.24,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '400a366790bd07ffd8c51faac9fbcdef',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -67.92,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e166c6487b4f799393831a7d76b51828',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6aa135ede42d442c9cdd1a1225bd83dc',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a517d5ef34912d92316cf1acd926a27d',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '866b47ff20660bbcaa91d5aee96aa150',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-11-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ccc9f0dc0b92135e0832adf0c6bcf2b2',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-11-03T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4ef7a42e3ec4a95185da671caa586bf3',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.55,
        timestamp: '2018-11-06T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c2c165c01a818005e3e90f31bd42f276',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-07T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bd18fe0de52572d6c976e1ce007c487c',
        description: 'Cash Notemachine ',
        currency: 'GBP',
        amount: -30.0,
        timestamp: '2018-11-07T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e75c34a47f4e81e86daabc40f9c05f53',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 116.4,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '7ecc0e943393800d30f7a8048e3fcfd3',
        description: 'Cash in HSBC 09Nov',
        currency: 'GBP',
        amount: 60.0,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '74b48d90ca6f31c9f500143ef8a9bac7',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'aeb505808bc6e7c4ab9021e4a23aa669',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3c64a4738ec0093351964353246251da',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c4419650607bd89459d13429421b7e70',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '22aae2c9a2b551fe39a7321b3358b636',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '454220c25d4018623c6b37d8a387b71f',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-11-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8622afd73d4d0aab2fa1172fe6c34bb9',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '2ebe34ce78d459076c8fb3521e9f1492',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a1cfa47b09229e1864a9e87bd885ae3b',
        description: 'Cash RB Scot Nov13 Tesco Killburn',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4248186ed899cbfd7b1be4fd204c91db',
        description: 'Cash Barclay Asda Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'eef3ae0e211351985b654648802f6510',
        description: 'Cash BNKM Cooperative Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2bbec594745ae240b7af0ea72f2bf1fc',
        description: 'Cash BNKM Cooperative Nov14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd3a5fd2f47eae5481283591cf67a2d1f',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 136.31,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'dcee8a295aee10097da773f87bd9e572',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b7f3091d39b2471c8a1fd4ec21860158',
        description: 'Cash in HSBC 16Nov',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '22811d8499af85de8e628208b0c02775',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e7d7f65ac0723b99390404a8d39de611',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'da19539d157ce53dd3f83817a7b01bc1',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '66a7b36c3a6b704e65be475430f188d0',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-11-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '220cb49dddef4ffbc6d9cb8c3262937f',
        description: 'Cash in HSBC 17Nov',
        currency: 'GBP',
        amount: 250.0,
        timestamp: '2018-11-17T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '7755d4b2da73b3d6059afb8b8980aa3c',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-11-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ae01159256b90ccd03956a0b4fe835c9',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '50f643b0637d00a1672e7c8834bf611b',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -8.0,
        timestamp: '2018-11-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cc9dd56a426e7d954af00909f88e5c0a',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-11-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e5e6ad13601ca9f0ff454d59e8d82a2a',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-11-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a8c16bfb2b1f8c223aa5f2177c41b386',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-11-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '455625f6d2ee47452dd99e267d66da8f',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ee4bca792923bffc90b09ee18e381b66',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '74bf954b0d5d81f9effc3defdc7a4632',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1b48fce62a113f2f61e02ffb2a46346d',
        description: 'Cash Natwide Nov19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b3c937342f6671fc8206f78aae24d668',
        description: 'Poundstretcher',
        currency: 'GBP',
        amount: -29.97,
        timestamp: '2018-11-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '50b2d08e6672931d0f2594899c6e5d38',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -14.99,
        timestamp: '2018-11-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6b346ba3b5645ea43333366d2b17746c',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -11.99,
        timestamp: '2018-11-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c395ca00e912d30d00bebdbfbbdaab4a',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'caa7f6d0920b06c773c598265d345e9c',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-20T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '8c586b0fd42c552560129333711c8c85',
        description: 'Cash bnkm Nov20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a5312625652f789fcb3bdf4379784cb9',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4f627fbf4250a1ef0c7f0c28c167515f',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-11-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'feece392910ca88c2b085f43f15388e2',
        description: 'Cash RB SCOT Nov21',
        currency: 'GBP',
        amount: -250.0,
        timestamp: '2018-11-21T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ea6d22270e4971b5c8919672e6b93aed',
        description: 'Cash Barclay Asda Nov21',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-11-21T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3eb09ad3f366579d2dad722262245dac',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'ae075d9207d9e22cd4232de314837f4b',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '6423a8f3643ed52035d114932c91281d',
        description: 'Cash bnkm Nov23',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '822626cb59e6e423b4eea2b70f898b90',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '10fa58144f6f5bd6bd28a8bb58b31f8f',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '332810286ee54bd146482b197bb2c2cd',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '75088a93ba17b62dd0c634923477b018',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'deb9e12fb9823ffd00bed1ba411686a2',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'afed96117c7dcb7b8de43553597b91f6',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-11-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f399c2ddb751b77d5518348c8489789f',
        description: 'Paypal ',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-11-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '87e078f2845ed206bb33bc9d5f0f53a5',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-11-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '248181654ffba1541f8d2cbe7c0cb650',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-11-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6244462fcbc474ebd643092c3245f3a4',
        description: 'Wickes',
        currency: 'GBP',
        amount: -28.98,
        timestamp: '2018-11-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6729eee5bf9b61b91447dfcbb9571b90',
        description: 'Cash RB Scot Nov25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-25T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c173d7092359f14730490627b248fd52',
        description: 'Petrol station M25',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-25T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0d2f51c295d1e3cadb92b291c5722bd3',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -28.23,
        timestamp: '2018-11-25T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9ad09f93031b3dd45b15b1ff57b1ce8d',
        description: 'Finchley services',
        currency: 'GBP',
        amount: -20.86,
        timestamp: '2018-11-25T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'edc530e9bd8aeb9ed3c5fbc54252c5a2',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-26T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'dd62e49f1b7c4a047e41d618490f3134',
        description: 'White Swan',
        currency: 'GBP',
        amount: -7.79,
        timestamp: '2018-11-26T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ccc3dcc238b1fc25d1aba10de3260593',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '57afe1bd504f19f560d194aea395961f',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c42ff4fdd5f3d02a4b4f5b1cc23105a1',
        description: 'Masons arms ',
        currency: 'GBP',
        amount: -12.98,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ff1d36b68b5ce3dde7a7bc3a75d27276',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '3d3a9b26cce36cd4d70ff9b890a6344b',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '41fad6ec308bbf80936e41b9d166afd3',
        description: 'Masons arms ',
        currency: 'GBP',
        amount: -12.98,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ca81d272794b44fe4db590c4516feb9a',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-11-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4b822efffda5486bd895459d0d520664',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-28T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ce22f6fa2eaba65a642d02bb671da9e7',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -8.48,
        timestamp: '2018-11-28T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '89c49e3ddaea451e73b86bad99973979',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-29T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '64c76f2a5955a912699a5cdfeba0914f',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-11-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '04b3a98db351d174816e92317e563d44',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-11-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3875125641ea7168aa6c0ca8b3a19f31',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'eb0493a0fc8607ab31431833771bdfac',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -15.8,
        timestamp: '2018-11-29T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c801403e4cf83f15b7733de45668ba01',
        description: 'Creation.co.uk',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '5c32542cee02db400803590959164965',
        description: 'DVLA-REGNUM',
        currency: 'GBP',
        amount: -19.25,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3319dbd81570f54d8bd8f7113252b4d5',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '78aa4f40c89f2fe0d4fc0d9af6b044a4',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 108.24,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f058223bd79bfb9c4c4f94c03af2a504',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -67.92,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '06b1e200ac03be11e4ae06ede49350ac',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b450eb25c47e752f3ffa1a4598589c9a',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cbbfc0405ee715436e1b3103c229a0fc',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '003c6c24d35cc6fd8164a37a1c503b49',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-12-02T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '47fd708d7742152192976e64ce69760c',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-12-03T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2e05060e45e8414c5b90f2554cba20e6',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.55,
        timestamp: '2018-12-06T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '28657911dba81dd4223367bb7935e6d5',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-07T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '81ce3180f3db59431f40108952784aa7',
        description: 'Cash Notemachine ',
        currency: 'GBP',
        amount: -30.0,
        timestamp: '2018-12-07T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '703139c2eb97fdeae956d7790c4a3d64',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 116.4,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '3677512400a5d7178e3a110c62d6626c',
        description: 'Cash in HSBC 09Nov',
        currency: 'GBP',
        amount: 60.0,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '180782195e3828d9bf5fc677b1044b96',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a5de6ff76850b7512d38e33338baf3d0',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '208025582fa8818308c64332a57a5233',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '643a28006f037dc3743b0a32a0fecc94',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '72649f47c6ff5590085872482465a57a',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'eb722122c08a59cd2746d5f20ffb4f1e',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-12-09T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '091f915af72bf26fdb236af0f8c44653',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '101fc5ac5d5e8c40904e53f9c849ea2b',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0c7a6111d8ff7da64d514d006016f550',
        description: 'Cash RB Scot Nov13 Tesco Killburn',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0d344c4b89b1c33507219af353dadb43',
        description: 'Cash Barclay Asda Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'cf34eb517e8f644abf7dd446fefd626a',
        description: 'Cash BNKM Cooperative Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '63224a02f90420dcb37501d5ada05b35',
        description: 'Cash BNKM Cooperative Nov14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '47c1242514fbb88328a47e8746c1ebac',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 136.31,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '268901a6f872571cc73982959895db27',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0b152e9fbd2241848c45249787eb970c',
        description: 'Cash in HSBC 16Nov',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '25153803a75b7a8bd846d1a6fd3d2d10',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8e02923a5bc08b2aee2538b864a0c741',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd463f69f42ea36d65a5622d8e2c2117e',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a82bccb215e885436e07acd8bf85d7d4',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-12-14T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '797a98564e71b0d6d3280339c5b5729f',
        description: 'Cash in HSBC 17Nov',
        currency: 'GBP',
        amount: 250.0,
        timestamp: '2018-12-17T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '5fd31d0bd59ee9b7e000d8ac63fb8a07',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-12-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6008119c068c195e9ee835f325cce067',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2423e62970bf9909b85214f085b89682',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -8.0,
        timestamp: '2018-12-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c42ec7bceca17b254b1540d8a646444b',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-12-17T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd93d8bed53dfda81ec1e249c39b0dda2',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-12-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'de488dddd2023f7d10260f47192efd4b',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-12-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ac86251f4e72ed536905e2b3c1479f27',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd953a558d278be5b57fb224a2602fbc9',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1fa7a2c70e05ebc438bc7a6621443255',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-18T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6021280059f0545cdc94386f16521193',
        description: 'Cash Natwide Nov19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1b1c4fa64d98ea3e1542a24ffbf4b5ee',
        description: 'Poundstretcher',
        currency: 'GBP',
        amount: -29.97,
        timestamp: '2018-12-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'fb9ea61ce16b3eafd0a7f926f9f42e72',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -14.99,
        timestamp: '2018-12-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '59806ea8cd51dccfc8dd49cbb8b632aa',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -11.99,
        timestamp: '2018-12-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '950f099f103fee62f1ec72e8bd68d7c7',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-19T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8112d9ffa6b781b33f874e08c3f9e0ee',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-12-20T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f8244a7d72c481c9ea07e083715546f5',
        description: 'Cash bnkm Nov20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0ed79939cc731a3230514d54222d8e52',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '03939353075d13ec030bad437c3a7661',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-12-20T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9ec20fe3f19e96c0241a1cf046c6d841',
        description: 'Cash RB SCOT Nov21',
        currency: 'GBP',
        amount: -250.0,
        timestamp: '2018-12-21T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '94b31366c745591b281cbf9e75007f95',
        description: 'Cash Barclay Asda Nov21',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-12-21T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd86e129a64294de911ae28c8647e8372',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '562f653ad77f75d5e68ef7c0388c6af6',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: '9fee0d3521e029c19391c477eaf47783',
        description: 'Cash bnkm Nov23',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9da1ad770e4262689724a97c4ae11c2b',
        description: 'Tombola.co.uk',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '90df155404a0faf820d550f1911d6c32',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6ac79a5a38f40d24902f99734db49fb5',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '34fdbb8a803d7f6ff1592cad78e5a6c8',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '17f4d3588e67d10dfaf90aac2a044dbf',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd44c09ef6400f2b7aad25416d4e754ed',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-12-23T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '48f405c50299c37886c672643832570a',
        description: 'Paypal ',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-12-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3b2561b663f03bc32a7f27c376a475e7',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-12-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '916fa70affe1a946428688c25336ce61',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-12-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9cdfcf990f17ded35b6c0a317536440b',
        description: 'Wickes',
        currency: 'GBP',
        amount: -28.98,
        timestamp: '2018-12-24T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bdeb49bef4d411524e55f8c6beea0e9b',
        description: 'Cash RB Scot Nov25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-25T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'dc717559f149c91f6cbaba41a9d6b3ac',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-26T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9d8c826014870df533f852a153b2ce47',
        description: 'White Swan',
        currency: 'GBP',
        amount: -57.79,
        timestamp: '2018-12-26T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a9e844341235bdb100800dcda803e277',
        description: 'Work and child TC',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-12-27T00:00:00.000+00:00',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c77644d86550753cb65b5fb1928ce164',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0fe31de76898aa1b29f2994a85c761dd',
        description: 'Masons arms ',
        currency: 'GBP',
        amount: -12.98,
        timestamp: '2018-12-27T00:00:00.000+00:00',
        transaction_type: 'debit'
      }
    ].freeze
  end
end
