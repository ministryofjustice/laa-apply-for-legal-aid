class ProviderDetailsCreator
  def self.call(provider)
    new(provider).call
  end

  attr_reader :provider

  def initialize(provider)
    @provider = provider
    @passported_permission = Permission.find_by(role: 'application.passported.*')
    @non_passported_permission = Permission.find_by(role: 'application.non_passported.*')
  end

  def call
    provider.update!(
      firm: firm,
      offices: offices,
      name: provider_name,
      contact_id: contact_id
    )
    provider.update!(selected_office: nil) if should_clear_selected_office?
  end

  private

  def provider_name
    ''
  end

  def should_clear_selected_office?
    !provider.selected_office.nil? && !provider.selected_office.id.in?(offices.pluck(:id))
  end

  def firm
    current_firm = Firm.find_or_create_by!(ccms_id: firm_id).tap do |firm|
      firm.update!(name: firm_name)
      firm.offices << offices
    end
    current_firm.permissions << @passported_permission unless current_firm.permissions.include?(@passported_permission)
    current_firm.permissions << @non_passported_permission unless current_firm.permissions.include?(@non_passported_permission)
    current_firm
  end

  def offices
    provider_details[:providerOffices].map do |ccms_office|
      Office.find_or_initialize_by(ccms_id: ccms_office[:id]) do |office|
        ccms_office[:name] =~ /-(\S{6})$/
        office.code = Regexp.last_match(1)
      end
    end
  end

  def firm_id
    provider_details[:providerFirmId]
  end

  def firm_name
    # Remove the code at the end.
    # "Pearson & Pearson -0A1234" becomes "Pearson & Pearson"
    # Remove " Office No. n" at the end if it's there because created by MockProviderDetailsRetriever
    #
    name = provider_details[:providerOffices].first[:name]
    name.sub(/Office No. \d+/, '').sub(/-\S{6}$/, '').strip
  end

  def contact_id
    contact[:id] if contact
  end

  def contact
    provider_details[:contacts]&.find { |contact| contact[:name].casecmp(username).zero? }
  end

  def username
    provider.username
  end

  def provider_details
    @provider_details ||= ProviderDetailsRetriever.call(provider.username)
  end
end
