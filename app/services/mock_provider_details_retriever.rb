class MockProviderDetailsRetriever
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
