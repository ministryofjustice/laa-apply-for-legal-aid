class MockProviderDetailsRetriever # rubocop:disable Metrics/ClassLength
  # This class simulated a CCMS API to get information about providers.
  # It accepts a provider username as a parameter.
  # In order for the response to be consistent per username but also not always the same for each username,
  # we generate a number from the username and use that number to generate the values from the response.

  def self.call(username)
    new(username).call
  end

  attr_reader :username

  def initialize(username)
    @username = username
  end

  def call
    puts "**** Using #{self.class} to retrieve Provider Details" unless Rails.env.test?
    provider_details
  end

  private

  def provider_details
    case username
    when 'NEETADESOR'
      neetadesor_user
    when 'MARTIN.RONAN@DAVIDGRAY.CO.UK'
      martinronan_user
    when 'HFITZSIMONS@EDWARDHAYES.CO.UK'
      hfitzsimons_user
    else
      all_other_users
    end
  end

  def neetadesor_user # rubocop:disable Metrics/MethodLength
    {
      providerFirmId: 22_381,
      contactUserId: 2_016_472,
      contacts: [
        {
          id: 34_419,
          name: contact_name(1)
        }
      ],
      feeEarners: [],
      providerOffices: [
        {
          id: 81_693,
          name: 'DESOR & CO-0B721W'
        }
      ]
    }
  end

  def martinronan_user # rubocop:disable Metrics/MethodLength
    {
      providerFirmId: 19_148,
      contactUserId: 494_000,
      contacts: [
        {
          id: 34_419,
          name: contact_name(1)
        }
      ],
      feeEarners: [],
      providerOffices: [
        {
          id: 137_570,
          name: 'David Gray LLP-0B721W'
        }
      ]
    }
  end

  def hfitzsimons_user # rubocop:disable Metrics/MethodLength
    {
      providerFirmId: 20_726,
      contactUserId: 284_410,
      contacts: [
        {
          id: 34_419,
          name: contact_name(1)
        }
      ],
      feeEarners: [],
      providerOffices: [
        {
          id: 85_487,
          name: 'Edward Hayes-137570'
        }
      ]
    }
  end

  def all_other_users
    {
      providerFirmId: firm_number,
      contactUserId: username_number,
      contacts: Array.new(number_of_contacts) { |index| contact_hash(index + 1) },
      feeEarners: [],
      providerOffices: Array.new(number_of_offices) { |index| office_hash(index + 1) }

    }
  end

  def number_of_contacts
    (firm_number % 3) + 1
  end

  def contact_hash(index)
    {
      id: contact_id(index),
      name: contact_name(index)
    }
  end

  def office_hash(index)
    {
      id: office_id(index),
      name: office_name(index)
    }
  end

  def office_name(index)
    "#{firm_name} Office No. #{index}-#{vendor_num(index)}"
  end

  def number_of_offices
    (username_number & 3) + 1
  end

  def contact_id(index)
    (username_number + index) % 1000
  end

  def office_id(index)
    (firm_number + index) % 1000
  end

  def firm_name
    @firm_name ||= "#{@username.sub(/-user\d+$/, '')} & Co."
  end

  def contact_name(index)
    "#{username.snakecase.titlecase}-#{index}"
  end

  # Generates a number from the username which is used to generate the values from the response
  def username_number
    @username_number ||= username.upcase.chars.map(&:ord).sum + user_digits
  end

  def firm_number
    @firm_number ||= firm_name.chars.map(&:ord).sum
  end

  def user_digits
    @username.gsub(/[^\d]/, '').to_i
  end

  # generate number in form NXNNNX
  def vendor_num(index)
    "#{index}#{firm_name[0].upcase}#{(firm_number * 100).to_s[0..2]}#{firm_name[1].upcase}"
  end
end
