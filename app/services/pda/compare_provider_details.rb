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
        log_message("Provider #{@provider.id} #{result.firm_id} does not match firm.ccms_id #{old_firm.ccms_id}") unless firm_ccms_id_matches?
        log_message("Provider #{@provider.id} \"#{result.firm_name}\" does not match firm.name \"#{old_firm.name}\"") unless firm_name_matches?
        log_message("Provider #{@provider.id} #{result.contact_id} does not match provider.contact_id #{@provider.contact_id}") unless contact_id_matches?
        log_message("Provider #{@provider.id} #{new_office_details} does not match #{old_office_details}") unless offices_match?
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

    def firm_ccms_id_matches?
      @firm_ccms_id_matches ||= old_firm.ccms_id.eql?(result.firm_id.to_s)
    end

    def firm_name_matches?
      @firm_name_matches ||= old_firm.name.eql?(result.firm_name)
    end

    def contact_id_matches?
      @contact_id_matches ||= @provider.contact_id.eql?(result.contact_id)
    end

    def offices_match?
      sorted_new_provider_offices == sorted_old_provider_offices
    end

    def old_firm
      @old_firm ||= @provider.firm
    end

    def old_office_details
      @old_office_details ||= old_provider_offices.map { |office| "#{office.ccms_id} #{office.code}" }.to_s
    end

    def sorted_old_provider_offices
      @sorted_old_provider_offices ||= old_provider_offices.map { |o| [o.ccms_id.to_s, o.code.to_s] }.sort
    end

    def old_provider_offices
      @old_provider_offices ||= @provider.offices
    end

    def new_office_details
      @new_office_details ||= new_provider_offices.map { |office| "#{office.id} #{office.code}" }.to_s
    end

    def sorted_new_provider_offices
      @sorted_new_provider_offices ||= new_provider_offices.map { |o| [o.id.to_s, o.code.to_s] }.sort
    end

    def new_provider_offices
      @new_provider_offices ||= result.firm_offices
    end
  end
end
