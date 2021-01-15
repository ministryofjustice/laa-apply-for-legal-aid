module Admin
  class ProviderDetailsService # rubocop:disable Metrics/ClassLength
    attr_reader :message

    def initialize(provider)
      @provider = provider
    end

    def check
      return :error unless provider_eligible_to_be_added?

      format_check_success_message
      :success
    end

    def create
      return :error unless provider_eligible_to_be_added?

      Provider.transaction do
        find_or_create_firm

        @provider.update!(
          firm: firm,
          offices: offices,
          contact_id: contact_id
        )
      end
      @message = "User #{@provider.username} successfully created"
      :success
    end

    def firm_name
      # Remove the code at the end.
      # "Pearson & Pearson -0A1234" becomes "Pearson & Pearson"
      #
      @firm_name ||= parsed_response[:providerOffices].first[:name].sub(/-\S{6}$/, '').strip
    end

    private

    def provider_eligible_to_be_added?
      if Provider.exists?(username: @provider.username)
        @message = "User #{@provider.username} already exists in database"
        return false
      end

      return false unless parse_uri

      format_error_message if raw_response.code != '200'
      return false if @message

      format_no_contact_message if contact_id.nil?
      return false if @message

      true
    end

    def format_error_message
      @message = if raw_response.code == '404'
                   "User #{@provider.username} not known to CCMS"
                 else
                   "Bad response from Provider Details API: HTTP status #{raw_response.code}"
                 end
    end

    def format_unicode_username
      @message = "'#{@provider.username}' contains unicode characters, please re-type if cut and pasted"
    end

    def format_check_success_message
      @message = "User #{@provider.username} confirmed for firm #{firm_name}"
    end

    def format_no_contact_message
      @message = "No entry for user #{@provider.username} found in list of contacts returned by CCMS"
    end

    def normalized_username
      @provider.username.upcase.gsub(' ', '%20')
    end

    def provider_details_url
      File.join(Rails.configuration.x.provider_details.url, normalized_username)
    end

    def parsed_response
      @parsed_response ||= JSON.parse(raw_response.body, symbolize_names: true)
    end

    def raw_response
      @raw_response ||= Net::HTTP.get_response(@parsed_uri)
    end

    def parse_uri
      @parsed_uri = URI.parse(provider_details_url)
    rescue URI::InvalidURIError
      format_unicode_username
      false
    end

    def firm
      @firm ||= find_or_create_firm
    end

    def offices
      @parsed_response[:providerOffices].map do |ccms_office|
        Office.find_or_initialize_by(ccms_id: ccms_office[:id]) do |office|
          ccms_office[:name] =~ /-(\S{6})$/
          office.code = Regexp.last_match(1)
          office.firm = firm
        end
      end
    end

    def contact_id
      username = @provider.username.upcase
      contact = parsed_response[:contacts].detect { |c| c[:name] == username }
      contact&.fetch(:id)
    end

    def find_or_create_firm
      ccms_firm_id = parsed_response[:providerFirmId]
      firm = Firm.find_by(ccms_id: ccms_firm_id)
      if firm.present?
        firm.update(name: firm_name) unless firm.name == firm_name
      else
        firm = Firm.create(name: firm_name, ccms_id: ccms_firm_id)
      end
      @firm = firm
    end
  end
end
