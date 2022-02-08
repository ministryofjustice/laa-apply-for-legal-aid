class HostEnv
  def self.environment
    return Rails.env.to_sym unless Rails.env.production?

    case root_url
    when /staging.apply-for-legal-aid.service.justice.gov.uk/
      :staging
    when /.apps.live-1.cloud-platform.service.justice.gov.uk/
      :uat
    when /apply-for-legal-aid.service.justice.gov.uk/
      :production
    else raise "Unable to determine HostEnv from #{root_url}"
    end
  end

  def self.development?
    environment == :development
  end

  def self.test?
    environment == :test
  end

  def self.uat?
    environment == :uat
  end

  def self.staging?
    environment == :staging
  end

  def self.production?
    environment == :production
  end

  def self.staging_or_production?
    environment.in?(%i[staging production])
  end

  def self.root_url
    Rails.application.routes.url_helpers.root_url
  end
end
