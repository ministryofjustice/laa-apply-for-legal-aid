class ProviderDetailsCreator
  def self.call(provider)
    new(provider).call
  end

  attr_reader :provider

  def initialize(provider)
    @provider = provider
  end

  def call
    provider.update!(
      firm: firm,
      details_response: provider_details,
      offices: offices,
      name: provider_name,
      user_login_id: contact_id
    )

    provider.update!(selected_office: nil) if should_clear_selected_office?
  end

  private

  def provider_name
    provider_details[:contactName]
  end

  def should_clear_selected_office?
    !provider.selected_office.nil? && !provider.selected_office.id.in?(offices.pluck(:id))
  end

  def firm
    Firm.find_or_create_by!(ccms_id: firm_id).tap do |firm|
      firm.update!(name: firm_name)
      firm.offices << offices
    end
  end

  def offices
    provider_details[:providerOffices].map do |ccms_office|
      Office.find_or_initialize_by(ccms_id: ccms_office[:officeId]) do |office|
        office.code = ccms_office[:smsVendorSite]
      end
    end
  end

  def firm_id
    provider_details[:providerOffices].first[:providerfirmId]
  end

  def firm_name
    # Remove the code at the end.
    # "Pearson & Pearson -0A1234" becomes "Pearson & Pearson"
    provider_details[:providerOffices].first[:officeName].split('-')[0..-2].join('-').strip
  end

  def contact_id
    provider_details[:contactId]
  end

  def provider_details
    @provider_details ||= ProviderDetailsRetriever.call(provider.username)
  end
end
