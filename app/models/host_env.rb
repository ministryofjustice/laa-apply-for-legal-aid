class HostEnv
  def self.environment
    return Rails.env.to_sym unless Rails.env.production?

    if /staging.apply-for-legal-aid.service.justice.gov.uk/.match?(root_url)
      :staging
    elsif /.apps.live-1.cloud-platform.service.justice.gov.uk/.match?(root_url)
      :uat
    elsif /apply-for-legal-aid.service.justice.gov.uk/.match?(root_url)
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

  def self.root_url
    Rails.application.routes.url_helpers.root_url
  end
end
