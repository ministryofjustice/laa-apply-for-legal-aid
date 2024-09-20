module PDA
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
        firm:,
        offices:,
        name: provider_name,
        contact_id:,
      )
      provider.update!(selected_office: nil) if should_clear_selected_office?
    end

  private

    def provider_name
      ""
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
      provider_details.firm_offices.map do |ccms_office|
        Office.find_or_initialize_by(ccms_id: ccms_office.id) do |office|
          office.code = ccms_office.code
        end
      end
    end

    def firm_id
      provider_details.firm_id
    end

    def firm_name
      provider_details.firm_name
    end

    def contact_id
      provider_details.contact_id
    end

    def username
      provider.username
    end

    def provider_details
      @provider_details ||= PDA::ProviderDetailsRetriever.call(username)
    end
  end
end
