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
        transaction_id: '404ebd7035e7c97960f3ce7a4a4f8811',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-09-27 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2658d44b99cc6605d59106d9b8336e67',
        description: 'Tombola.co.uk betting betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-09-28 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '32a3f714fbd462be57590998171042c9',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -8.48,
        timestamp: '2018-09-28 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e878f6ea566d2363e9bbe2a5b613bc3c',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-09-28 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '70f61da5bdc38978ae6b93e35e73b35c',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-09-29 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'eccab9a273a1f411c335d4ea183e4989',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-09-29 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '28a81010ca25c35572c1c1f5b8ba8fed',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-09-29 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '03885202ce2190bdfb35dea7dae4e57f',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -15.8,
        timestamp: '2018-09-29 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd8e84541279f7f5ee153f01337ff4050',
        description: 'Cash RB Scot Oct01 Tesco Killburn',
        currency: 'GBP',
        amount: -40.0,
        timestamp: '2018-10-01 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '99a9aa240e3c4f5ed88d1dba8b3c2129',
        description: 'Creation.co.uk loan repayment',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '01e55198bf47e173c2232eea0043342e',
        description: 'DVLA-REGNUM',
        currency: 'GBP',
        amount: -19.25,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bcf42b1158740f86cd000de4a7de2bed',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '20d48c568bf9979c164d869891883626',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 108.24,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '13c9007c1973012c7936c3e2a1a0b462',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -67.92,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'aa57b16525f4aab9d41672623b30020a',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '91232676f08b29e23e3500a2e6016569',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a972e5088706dd1d9cc7da9d24a45751',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a715f517819198607775b00a98798d8b',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-10-02 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b22048b755fe3f5efee3085a607f8f68',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-10-03 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0239f22fd09f5f91e8686e8460f6f0aa',
        description: 'Sky digital reversal of 03-10',
        currency: 'GBP',
        amount: 56.79,
        timestamp: '2018-10-03 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '3f1e17d9f5a276ca95dc39fe8b028213',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.55,
        timestamp: '2018-10-05 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f6aeabd993cc74915aa0db726a82d30f',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-07 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '67751f3499363dace815aaf785ed7879',
        description: 'Cash Notemachine ',
        currency: 'GBP',
        amount: -30.0,
        timestamp: '2018-10-07 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '823c07432e749a0187a93f1e20f7b074',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 116.4,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '90c4638555d096375a3dbf418568a9ef',
        description: 'Cash in HSBC 09Oct',
        currency: 'GBP',
        amount: 60.0,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '51b3d6b29e6998caa1ad3ac5803b9b7e',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c66b1358a25f92eaba9a778dbe71db6f',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '78932bdf0d80bad6634e3ec6a1b62080',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4167b2c23d6e257c4dd421a897816c18',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4dc1eab5423de4608897e78827c4b650',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '49a217e2b0fcd14f049898eb2643995d',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-10-09 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7392cb21856d37d7f63639c0772cafc8',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-10-11 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f500bc8e11ca516bb940d5c7173d530b',
        description: 'Sky digital reversal of 11-10',
        currency: 'GBP',
        amount: 56.79,
        timestamp: '2018-10-11 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '9c23356b7811ee03b07972b2fc486eee',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-12 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '2f6d127a7f050c1a96086316cc4ae09b',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-10-13 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1c3d30a9dac57c799bd06a51d5d1fac6',
        description: 'Cash RB Scot Oct13 Tesco Killburn',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-10-13 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '469278a2d486b6f8a9b5c4eec332864e',
        description: 'Cash Barclay Asda Oct13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '685e6ac5d32b22b9d324741e08127ee1',
        description: 'Cash BNKM Cooperative Oct13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '452243c8960c6432e4cda99db815e984',
        description: 'Cash BNKM Cooperative Oct14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-13 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f496f956345d10a802856fe140db5548',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '44dd98cbd65454aa7e2ac1dc4b357b2e',
        description: 'Cash in HSBC 16Oct',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '048b27ae963cb3b9eced11a235813de0',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '761d4df896d4458b13a133b86cc18663',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e8b9ae498f0eb497bb5c62a90b074ca8',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '5c6e30e67580ad4c99d48b7fe2962c53',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-10-14 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'eacd54f6515af829b2104768c1710323',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 136.31,
        timestamp: '2018-10-16 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '920430193f0e9d38e27c9260a3565e8b',
        description: 'Mum transfer in: washing machine',
        currency: 'GBP',
        amount: 350.0,
        timestamp: '2018-10-17 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'fad6d687fe981d54d3b98871ad33efa0',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-10-17 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0f339880843fc89f85cc97afa3161124',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-17 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1df72debcd8a119a080e83b2af81eadc',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -8.0,
        timestamp: '2018-10-17 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '12894b7fdbe7039e31e9bb502a46ff2e',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-10-17 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9f35de64548a7574989f2186d809bd4c',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-10-18 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '189dc17d0aedc7ce4fe1b6787dbff5a4',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-10-18 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '68ff9bd63581a0271cce173a8184a728',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-18 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a892592cd59f849b6fb085c36590f6a2',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-18 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '99b0c1c504b3969cd1f290218cd48975',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-18 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9228a04b214d2ce66998276c58db8b87',
        description: 'Cash Natwide Oct19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '798f289e2d48021c2efd00a7df4486c4',
        description: 'Poundstretcher',
        currency: 'GBP',
        amount: -29.97,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f044b438a0545d67282968f9792f2f01',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -14.99,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e5b014c0e8d0cbe05da675dd5c08bac9',
        description: 'Halfords Kilburn',
        currency: 'GBP',
        amount: -11.99,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c1050030cbe62042392eaca02656f2c1',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '5820229ec3085d4c90ca5dc243f0277d',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-19 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '95b63b68a1adfa43e47b45aa91148b73',
        description: 'Cash bnkm Oct20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-20 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '706915cdf8ea65feca0a8883a88dfce9',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-20 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8f952ae74cc7e5dbe9db6b3fb1a39602',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-10-20 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '3d17117ced461f7b347b02297f5c79f5',
        description: 'Cash RB SCOT Oct21',
        currency: 'GBP',
        amount: -250.0,
        timestamp: '2018-10-21 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4b539c1baa6d47d0b2a4b1a1c82ed454',
        description: 'Cash Barclay Asda Oct21',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-10-21 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '19f4a2bc8022e3770914e979f747b932',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'ddbe70d2531ebecf645e6bb9b52fa254',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '1eb71d0b71269f9b54c1952810c04d27',
        description: 'Cash bnkm Oct23',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e0945ee3c00128b3850d187e4c3379b4',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '57998e6845614b908d2ea7ab61232981',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '93a0875e36438075f476d7bad88daf09',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b60245425cba058f33eb6359b0fab799',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '465203292980e4c37308b61dc33ab468',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6e2dc04d96cc838cf665e1fd93f4e9b8',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-10-23 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8af4b7c49d2341e69cd68be8b4d7d87b',
        description: 'Paypal ',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-10-24 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd2edb9bd38854211c810f4db922b6230',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-10-24 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c17b274dfd473e61e5bf55aefb324303',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-10-24 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7299187c8389dd5a45dbbd7eb1c8aa84',
        description: 'Wickes',
        currency: 'GBP',
        amount: -28.98,
        timestamp: '2018-10-24 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bd60c95ce4e96413814f3a4b6f41ecdb',
        description: 'Cash RB Scot Oct25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-25 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7694423759c754c470fd7dc553ef73d8',
        description: 'Petrol station M25',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-10-25 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7b33e4f1d00d2a8cd1215316b6a9cd6b',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -28.23,
        timestamp: '2018-10-25 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '68b11602acae4d1ddb53e76f4cbde4ed',
        description: 'Finchley services',
        currency: 'GBP',
        amount: -20.86,
        timestamp: '2018-10-25 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c9271583124c7b53fa9d19731823991e',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-26 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4841e116febbb5d75a8ac0726b9ed625',
        description: 'White Swan',
        currency: 'GBP',
        amount: -7.79,
        timestamp: '2018-10-26 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '307d6914b18cfd21887ae07acae5f3aa',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-10-26 00:00:00 +0100',
        transaction_type: 'credit'
      },
      {
        transaction_id: '31303c6f3a664eff2da223fc1db7156a',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-10-27 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7a079a0bc069e6be7b236ce71e68c4cd',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-27 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f3b0a5c116dfceb1480310b5e9bff7e9',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -8.48,
        timestamp: '2018-10-28 00:00:00 +0100',
        transaction_type: 'debit'
      },
      {
        transaction_id: '165ff9e48927d99e833627128dd7232f',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-10-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bbc3a2d379c51f60a726d5ccaa9f37e2',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-10-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bdbebce375668bd6ce742464a3c23adc',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-10-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '826db6f966ab3964eb0d42f1268084db',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 188.24,
        timestamp: '2018-10-30 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '98bea28e66b58fd50b418f87be5cf00b',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '42405db7e6ea2f14dba178903ec73cc0',
        description: 'Creation.co.uk loan repayment',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '309b8c8a427816638842a18fee5f3bd3',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7351a0b1c46c5a7aeb96b0a979e32fe9',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -33.56,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0333977bbfec10cabd80a328ef7fe35b',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '5e2b065b910ea1c629f72cc1836f04d1',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '046f71e596a58acfbb194c4bfb532f1e',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4316779bd8923156191a0ea7241ec0e1',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-11-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '046ff4c21d27fdb5a60e99d2cba11c8a',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 186.4,
        timestamp: '2018-11-06 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '150f6f8f11019a1a134f744ce01986c3',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-07 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6b5760d452b06928204a72118c790920',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c0c96a39e612d09729a4350295e9402d',
        description: 'Cash in from betting win',
        currency: 'GBP',
        amount: 120.0,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '285c8a494429d4216200ba8ed437d6bd',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6bb946b8db3d7f4cc54094dfe77fc983',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a074f736cc8ebc623b71683072074cbd',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8d8919aab790cc23653c0867c1000472',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6e565829c4a41ffda4a9a72e9f26a0a9',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '800b117fae13dadc2f9d06846c6ca3a9',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-11-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9c921a2392026124b84eaca48eda5471',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '372b63e933a88bee4c9cab04ac7357d5',
        description: 'Cash RB Scot Nov13 Tesco Killburn',
        currency: 'GBP',
        amount: -50.0,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ba667625c45027b4e29fcb940236a0e9',
        description: 'Cash Barclay Asda Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c47e4cd36cc6697da57e637827242de9',
        description: 'Cash BNKM Cooperative Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '127ebc8a2c2502c4c66fd7758da2ff8a',
        description: 'Cash BNKM Cooperative Nov14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bf52bfa74600cfce613574648b5817e0',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 175.31,
        timestamp: '2018-11-13 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '4726ffbae01c69f4032440c8a85a7fc7',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '482b93b265ada66916a82934fd48c38c',
        description: 'Friend transfer in',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f4640880fb75ee3767d26fdb3f9c86f9',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '41f7eb2dc98a708e5ecb0378b73b9142',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f22d2505b27d374390f443862d7f4eba',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '41e7c12f9b548a0bde9fbb1180411ceb',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-11-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a19ed4af22ba4ffe318ccf9e50c9c06e',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-16 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '12f7e44cc05f123eb3d5ad3e2924153e',
        description: 'Cash in HSBC 17Nov',
        currency: 'GBP',
        amount: 150.0,
        timestamp: '2018-11-17 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'b90856277329038c79cb7108d789e5e3',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-11-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6ae432018c2e6053547a27c93c62dbce',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'de07f170d71cb43118649eac2fb7f1e3',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -8.0,
        timestamp: '2018-11-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '192a8cf92bf62d1498588f35aa634dae',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-11-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ed6d00e6a65076b6edf58897ba84f2c9',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-11-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9b2e909e95b6dee5ae45a7be1c3bbbd7',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-11-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '51c593c1343ad1c020006bda5a23d784',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0e7cae47496ab4b746bcc6318e7fad36',
        description: 'Cash Natwide Nov19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-19 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9d665b6f2a04b4e98020b12c174788f4',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-19 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '849a0d00e2eb099835e169dbb90ac095',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-23 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '06d25db946831a78a1df0e8324a3c5c7',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-11-20 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'df8acc552b47d0ee50280fb9cc36baab',
        description: 'Cash bnkm Nov20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e21881923e9b5c3f9d8b3584cf63581a',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ab54dbb97c7422841eb2ef1cb7ecbeaf',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-11-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '0ea78ca5cb1958cf251845c1c57ab261',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-11-20 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '4168be17344b42f5c741a7079f16cbc0',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-11-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '70e1c87f553ceb86ddab878fdfc52962',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-11-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '49e1921be30fb9aff37214200c2887f0',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-11-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bf23c63a016deef9c9a24fcf49689983',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-11-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '98a5bfb726e89869a2f3981ad6ad655a',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-11-24 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'dc6ddcf1c0983f13763991d5e7166674',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-11-24 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6af1b8ffcbf9b26ed3ec87a7caa593d5',
        description: 'Cash RB Scot Nov25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-25 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e2f5ae67101d37b7107cff2274ab8347',
        description: 'Petrol station M25',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-11-25 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a810b56b9f5c69033d0d43220db94dea',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -28.23,
        timestamp: '2018-11-25 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '685ebb52654346ccffb5c5065d5b373f',
        description: 'Finchley services',
        currency: 'GBP',
        amount: -20.86,
        timestamp: '2018-11-25 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b98b581a0e4688faa1516ac603202d10',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-11-26 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '36ae1013fa04a4202ab9dd82a9b2aaa0',
        description: 'White Swan',
        currency: 'GBP',
        amount: -7.79,
        timestamp: '2018-11-26 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b3ef052d7602ec07fa9ac31d29843d80',
        description: 'Cash Bnkm Cooperative',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-27 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bdb9dc9f01f245527f39034250550098',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 108.24,
        timestamp: '2018-11-27 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'ec6552fd15dc0c52b2ec1eb480d7ca75',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -11.1,
        timestamp: '2018-11-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c8f7c765b297424fa20ae93ed5430564',
        description: 'Lloyds Pharmacy',
        currency: 'GBP',
        amount: -2.19,
        timestamp: '2018-11-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1b0541f418c434d8eb407999d9c71752',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-11-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '97520a5554a5919dacf85392aa5d480e',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -15.8,
        timestamp: '2018-11-29 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8264b8a2bed6069b66357d9c37c3a56c',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-11-30 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'c28794ba2a0eaf0dc6d7b893503fa1ec',
        description: 'Creation.co.uk loan repayment',
        currency: 'GBP',
        amount: -54.8,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '83ddf07b29440ea083a7d508072937f5',
        description: 'DVLA-REGNUM',
        currency: 'GBP',
        amount: -19.25,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b5e426a2320c99dcd9926d98391e8223',
        description: 'H3G',
        currency: 'GBP',
        amount: -34.88,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '522569351629ebdfeb1f06a149ea2606',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -67.92,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7b3205602e37c97f070f371e0250c9cb',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '99da00b660fb37b918652103cc6dfd17',
        description: 'Garden Centre',
        currency: 'GBP',
        amount: -6.99,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '237e17abc5831dcc9d24f0e89cec538a',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -53.33,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4bb90dba33f2e2b5f8947904b739d5f2',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-12-02 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f95e786e6b3200756c0f024f1831719c',
        description: 'Sky digital',
        currency: 'GBP',
        amount: -56.79,
        timestamp: '2018-12-03 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9fec907b702833a96fe93caa072b22aa',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 188.3,
        timestamp: '2018-12-04 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'ce95b339c00642801089ff1fda5aa15a',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.55,
        timestamp: '2018-12-07 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'd68834b500cde1199d682c7a71bee843',
        description: 'Cash Natwest 06Oct',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-07 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c6cd3347d3151a437474c6ca13381f64',
        description: 'Cash Notemachine ',
        currency: 'GBP',
        amount: -30.0,
        timestamp: '2018-12-07 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '235259e42fd0a13cbcde4997d87216b7',
        description: 'Cash in HSBC 09Nov',
        currency: 'GBP',
        amount: 80.0,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '3f7c4d2b998a2939f73709ee1cf9e413',
        description: 'Jess Jones Rent 0735454',
        currency: 'GBP',
        amount: -1048.5,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f7bb69034a32b67500ccf29d1d8b2a7e',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '1ae5a722ad53be26525a4bf77f93042d',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -19.0,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'bdd717192de9bd061a26e8369f1fd24d',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -3.0,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c5eb28a1038cb707ad18c29ffdbb4664',
        description: 'Queens park',
        currency: 'GBP',
        amount: -11.11,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'f9fea196283a1253abcb6266fefad416',
        description: 'McDonalds Kilburn',
        currency: 'GBP',
        amount: -15.11,
        timestamp: '2018-12-09 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '49089576c8e6b95b26401f0b5e55fb2b',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 116.4,
        timestamp: '2018-12-11 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '4df9345314abbcbfd3e4c882e0364963',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '672bdeaeb398bc4f39b5cf2a0b771ef9',
        description: 'Hastings direct',
        currency: 'GBP',
        amount: -49.73,
        timestamp: '2018-12-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '562009e2c2808a15b4bfee0c78e3f331',
        description: 'Cash Barclay Asda Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e23d4358b0a08d7928444cecffd6e6be',
        description: 'Cash BNKM Cooperative Nov13',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e8f3237a6fb56b3eaa30257e6165fcd9',
        description: 'Cash BNKM Cooperative Nov14',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-13 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c5502c09b9137828e8c533224d6a692e',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -37.52,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '8e91604136b9fafc43f3244b9bf2a614',
        description: 'Cash in HSBC 16Nov',
        currency: 'GBP',
        amount: 130.0,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '81e1cdc5f21b136d4a0adc2eeaf0fc34',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.45,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c5fa49098d481df09232840f63b4ce69',
        description: 'Ben Stevens Kilburn',
        currency: 'GBP',
        amount: -8.09,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '39dd7d1c12581fa3bf3160aa87d2a5b8',
        description: 'Golders Green Park',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '4a9e791683e5e383ba49ca634a90c01e',
        description: 'Just Eat London',
        currency: 'GBP',
        amount: -11.9,
        timestamp: '2018-12-14 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd75f0c3930691a6b3857e4ed0f44f91a',
        description: 'Asda superstore',
        currency: 'GBP',
        amount: -48.0,
        timestamp: '2018-12-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'daf3bb402dffafb76d35ed80012623c7',
        description: 'BP petrol station',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c7e9a226cd8fea88c8547a1d642aa623',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -4.47,
        timestamp: '2018-12-17 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'ba9bec9d78b5384ca7a23d2b96f6c231',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 136.31,
        timestamp: '2018-12-18 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: '137928c827ea254c64708b2dfe87a65e',
        description: 'Pre-notified fees and charges',
        currency: 'GBP',
        amount: -13.0,
        timestamp: '2018-12-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b39eaeecb67d2ba461b7ef855ced627e',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-12-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a74c7f5d56a053900db2c9d8e7be0c5f',
        description: 'Tesco Pump ',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-18 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6d053c105660fb81a101c637b2aa543e',
        description: 'Child benefit',
        currency: 'GBP',
        amount: 82.8,
        timestamp: '2018-12-18 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f26b380eedc06c4417dfbd664947ffad',
        description: 'Cash Natwide Nov19',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-19 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a188e51bbe81a08f4dc4b2a675a36711',
        description: 'Shell Finchley',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-19 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '02e19a82af9e71259cfc80b3126c7203',
        description: 'Mum transfer in',
        currency: 'GBP',
        amount: 250.0,
        timestamp: '2018-12-21 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f31299749fef9dce38acc7c3efbbce6d',
        description: 'Work and child tax credit',
        currency: 'GBP',
        amount: 165.65,
        timestamp: '2018-12-21 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'f972d8c956b8764abada72116853bf0d',
        description: 'Cash bnkm Nov20',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c9a88198f42d81e4f96bdb3b171733b0',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c125d46d2323b80c106d93b3223d7786',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.95,
        timestamp: '2018-12-20 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'd37278626dce7c1a99d880c5f2e4a818',
        description: 'Cash bnkm Nov23',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '905f0038679c8d183609e4613bdbae40',
        description: 'Tombola.co.uk betting',
        currency: 'GBP',
        amount: -10.0,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'c75368c31d0bfedfa304883d64ed0bf8',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '6dfa23b3431dc4be0b444ccd6a410e28',
        description: 'Tesco ',
        currency: 'GBP',
        amount: -12.75,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7f181957baf0b5906bfb42ae83048ba6',
        description: 'Mastercard',
        currency: 'GBP',
        amount: -40.36,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'e3ff0ebab58f9240d583d5355210dbff',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.28,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2c666f19a58dd436a21c9b9c5fa57f3b',
        description: 'Mcdonalds Kilburn',
        currency: 'GBP',
        amount: -8.07,
        timestamp: '2018-12-23 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'a850629e4acec33370d9d0e5e07d2a66',
        description: 'Paypal ',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-12-24 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '40ec82bee83dae67c99632e997968fd5',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -12.0,
        timestamp: '2018-12-24 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: 'b73ae492bb9f17c2890c33094b099c6e',
        description: 'British Gas Trading Britishgas.co',
        currency: 'GBP',
        amount: -9.0,
        timestamp: '2018-12-24 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '9d09cc5b1569f4adfe93fd83c8bf1d91',
        description: 'Care Home Ltd Salary',
        currency: 'GBP',
        amount: 174.77,
        timestamp: '2018-12-25 00:00:00 +0000',
        transaction_type: 'credit'
      },
      {
        transaction_id: 'd120b31afbde3d3b1ddaf252280933b6',
        description: 'Cash RB Scot Nov25',
        currency: 'GBP',
        amount: -20.0,
        timestamp: '2018-12-25 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '2efca86d30c96528e76fecae339161f1',
        description: 'A B Ltd Dublin',
        currency: 'GBP',
        amount: -5.0,
        timestamp: '2018-12-26 00:00:00 +0000',
        transaction_type: 'debit'
      },
      {
        transaction_id: '7c364db6519ab2f5437ff618bb386100',
        description: 'White Swan',
        currency: 'GBP',
        amount: -57.79,
        timestamp: '2018-12-26 00:00:00 +0000',
        transaction_type: 'debit'
      }
    ].freeze
  end
end
