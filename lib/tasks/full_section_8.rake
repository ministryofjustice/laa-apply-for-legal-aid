desc "Temporary task to set full section 8 permissions up on localhost"
task full_section_8: :environment do
  raise "rake full_section_8 can only be used in development" if HostEnv.production?

  full_section_8_permission = Permission.find_by(role: "application.full_section_8.*")

  Firm.all.each do |firm|
    next if firm.permissions.include?(full_section_8_permission)

    firm.permissions << full_section_8_permission
    firm.save!
  end
  Rails.logger.warn "All firms (#{Firm.count}) enabled for full section 8"
end
