desc "Temporary task to set employed journey up on localhost"
task employ: :environment do
  raise "rake employ can only be used in development" if HostEnv.production?

  Setting.setting.update!(enable_employed_journey: true)
  Rails.logger.warn "Employed journey feature flag enabled"

  employment_permission = Permission.find_by(role: "application.non_passported.employment.*")

  Firm.all.each do |firm|
    next if firm.permissions.include?(employment_permission)

    firm.permissions << employment_permission
    firm.save!
  end
  Rails.logger.warn "All firms (#{Firm.count}) enabled for employed applications"
end
