desc "Temporary task to set bank statement upload permissions up on localhost"
task bank_statement_upload: :environment do
  raise "rake bank_statement_upload can only be used in development" if HostEnv.production?

  bank_statement_upload_permission = Permission.find_by(role: "application.non_passported.bank_statement_upload.*")

  Firm.all.find_each do |firm|
    next if firm.permissions.include?(bank_statement_upload_permission)

    firm.permissions << bank_statement_upload_permission
    firm.save!
  end
  Rails.logger.warn "All firms (#{Firm.count}) enabled for bank statement upload"
end
