namespace :ptr_migrations do
  desc "Transfer a LegalAidApplication from one Office to another"
  task :laa_transfer_office, %i[mock app_id office_id] => :environment do |_task, args|
    args.with_defaults(mock: "true")
    mock = args[:mock].to_s.downcase.strip != "false"
    laa = LegalAidApplication.find_by(id: args[:app_id])
    office = Office.find_by(id: args[:office_id])

    if laa.nil? || office.nil?
      Rails.logger.info "LegalAidApplication or OFFICE does not exist"
      next
    end

    if laa
      Rails.logger.info "LegalAidApplication (#{laa.application_ref}) current office code: #{laa.office.code}"

      laa.update!(office: office) unless mock

      Rails.logger.info "LegalAidApplication (#{laa.application_ref}) successfully transferred to office code: #{laa.office.code}"
    else
      Rails.logger.info "LegalAidApplication not found"
    end
  end

  desc "Transfer a Provider from one Firm to another"
  task :provider_transfer_firm, %i[mock provider_id firm_id] => :environment do |_task, args|
    args.with_defaults(mock: "true")
    mock = args[:mock].to_s.downcase.strip != "false"
    provider = Provider.find_by(id: args[:provider_id])
    firm = Firm.find_by(id: args[:firm_id])

    if provider.nil? || firm.nil?
      Rails.logger.info "PROVIDER or FIRM does not exist"
      next
    end

    if provider
      Rails.logger.info "Provider (#{provider.email}) current firm #{provider.firm_name}"

      provider.update!(firm: firm, selected_office_id: nil) unless mock

      Rails.logger.info "Provider (#{provider.email}) successfully transferred to firm #{provider.firm_name}"
    else
      puts "Provider not found"
    end
  end

  desc "Delete unused or incorrect Firm"
  task :delete_firm_office, %i[mock firm_id] => :environment do |_task, args|
    args.with_defaults(mock: "true")
    mock = args[:mock].to_s.downcase.strip != "false"
    firm = Firm.find_by(id: args[:firm_id])

    if firm.nil?
      Rails.logger.info "FIRM does not exist"
      next
    end

    if firm
      firm.offices.each do |office|
        applications_in_office = LegalAidApplication.where(office: office).count

        if applications_in_office.zero?
          office.destroy! unless mock
          Rails.logger.info "Firm (#{firm.name}), Office (#{office.code}) deleted successfully"
        else
          Rails.logger.info "Firm (#{firm.name}), Office (#{office.code}) has #{applications_in_office} legal aid application associated with it. Skipping!"
        end
      end

      offices_in_firm = firm.offices.count

      if offices_in_firm.positive?
        Rails.logger.info "Firm (#{firm.name}) has #{offices_in_firm} office associated with it. Skipping!"
      else
        firm.destroy! unless mock

        Rails.logger.info "Firm (#{firm.name}), deleted successfully"
      end
    else
      Rails.logger.info "Firm not found"
    end
  end
end
