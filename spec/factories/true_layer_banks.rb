FactoryBot.define do
  factory :true_layer_bank do
    banks do
      [
        {
          provider_id: 'ob-bos',
          display_name: 'Bank of Scotland',
          logo_url: 'https://truelayer-client-logos.s3-eu-west-1.amazonaws.com/banks/banks-icons/ob-bos-icon.svg'
        },
        {
          provider_id: 'ob-hsbc',
          display_name: 'HSBC',
          logo_url: 'https://truelayer-client-logos.s3-eu-west-1.amazonaws.com/banks/banks-icons/ob-hsbc-icon.svg'
        }
      ]
    end
  end
end
