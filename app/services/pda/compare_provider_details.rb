module PDA
  class CompareProviderDetails
    # NOTE: This is intended as a temporary class while we switch from CCMS Provider Details API
    # to the new Provider Details API.
    # Once that change over is complete, the aim is that this can be removed.
    include MessageLogger

    def initialize(provider_id)
      @provider = Provider.find(provider_id)
    end

    def self.call(provider_id)
      new(provider_id).call
    end

    def call
      start_time = Time.zone.now
      result
      end_time = Time.zone.now
      log_message("start: #{start_time} end: #{end_time} duration: #{end_time - start_time} seconds")
      compare_result
    rescue PDA::ProviderDetailsRetriever::ApiRecordNotFoundError
      log_message("User not found for #{@provider.id}.")
    rescue PDA::ProviderDetailsRetriever::ApiError => e
      log_message("User #{@provider.id} #{e.message}")
    end

  private

    def compare_result
      if match?
        log_message("Provider #{@provider.id} results match.")
      else
        log_message("Provider #{@provider.id} #{result.firm_id} does not match firm.ccms_id #{firm.ccms_id}") unless firm_ccms_id_matches?
        log_message("Provider #{@provider.id} #{result.firm_name} does not match firm.name #{firm.name}") unless firm_name_matches?
        log_message("Provider #{@provider.id} #{result.contact_id} does not match provider.contact_id #{@provider.contact_id}") unless contact_id_matches?
        log_message("Provider #{@provider.id} #{pda_office_details} does not match #{provider_office_details}") unless offices_match?
      end
    end

    def result
      @result ||= PDA::ProviderDetailsRetriever.call(@provider.username)
    end

    def match?
      @match ||= [
        firm_ccms_id_matches?,
        firm_name_matches?,
        contact_id_matches?,
        offices_match?,
      ].all?
    end

    def firm
      @firm ||= @provider.firm
    end

    def provider_offices
      @provider_offices ||= @provider.offices
    end

    def provider_office_details
      @provider_office_details ||= provider_offices.map { |office| "#{office.ccms_id} #{office.code}" }.to_s
    end

    def pda_office_details
      @pda_office_details ||= result.offices.map { |office| "#{office.id} #{office.code}" }.to_s
    end

    def firm_ccms_id_matches?
      @firm_ccms_id_matches ||= firm.ccms_id.eql?(result.firm_id)
    end

    def firm_name_matches?
      @firm_name_matches ||= firm.name.eql?(result.firm_name)
    end

    def contact_id_matches?
      @contact_id_matches ||= @provider.contact_id.eql?(result.contact_id)
    end

    def offices_match?
      return false if provider_offices.count != result.offices.count

      result.offices.each do |office|
        provider_office = provider_offices.find_by!(ccms_id: office.id)
        return false if provider_office.code != office.code
      end
      true
    rescue ActiveRecord::RecordNotFound
      false
    end
  end
end
