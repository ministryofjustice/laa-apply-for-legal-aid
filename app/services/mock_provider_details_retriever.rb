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

  def neetadesor_user
    {
      providerOffices: [{
        providerfirmId: '19148',
        officeId: '81693',
        officeName: 'Desor & Co._81693',
        smsVendorNum: 'TestSMSVendorNum1',
        smsVendorSite: '0B721W'
      }],
      contactId: '2016472',
      contactName: contact_name
    }
  end

  def martinronan_user
    {
      providerOffices: [{
        providerfirmId: '19148',
        officeId: '137570',
        officeName: 'David Gray LLP_137570',
        smsVendorNum: 'TestSMSVendorNum2',
        smsVendorSite: 'TestSMSVendorSite2' # legal aid code/contract number e.g. 0B721W
      }],
      contactId: '494000',
      contactName: contact_name
    }
  end

  def hfitzsimons_user
    {
      providerOffices: [{
        providerfirmId: '20726',
        officeId: '85487',
        officeName: 'Edward Hayes_137570',
        smsVendorNum: 'TestSMSVendorNum3',
        smsVendorSite: 'TestSMSVendorSite3' # legal aid code/contract number e.g. 0B721W
      }],
      contactId: '284410',
      contactName: contact_name
    }
  end

  def all_other_users
    {
      providerOffices: Array.new(number_of_offices) do |office_index|
        provider_office(office_index)
      end,
      contactId: username_number * 3,
      contactName: contact_name
    }
  end

  def provider_office(office_index)
    # unique office_id for each office
    office_id = username_number * 2 + office_index

    # unique office_number for each office
    office_number = "office_#{office_id}"

    {
      providerfirmId: firm_id,
      officeId: office_id,
      officeName: "#{firm_name}-#{office_number}",
      smsVendorNum: ((office_id + firm_id) * 4).to_s,
      smsVendorSite: office_number
    }
  end

  def number_of_offices
    (username_number & 3) + 1
  end

  def firm_id
    @firm_id ||= firm_number
  end

  def firm_name
    @firm_name ||= "#{contact_name.sub(/\sUser\d+$/, '')} & Co."
  end

  def contact_name
    @contact_name ||= username.snakecase.titlecase
  end

  # Generates a number from the username which is used to generate the values from the response
  def username_number
    @username_number ||= username.upcase.chars.map(&:ord).sum
  end

  def firm_number
    @firm_number ||= calculate_firm_number
  end

  def calculate_firm_number
    username.sub(/-user\d+$/, '').upcase.chars.map(&:ord).sum
  end
end
