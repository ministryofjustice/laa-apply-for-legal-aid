class HostingEnvironment
  UAT_HOST_REGEX = /applyforlegalaid-uat/.freeze
  STAGING_HOST_NAME = 'applyforlegalaid-staging.apps.cloud-platform-live-0.k8s.integration.dsd.io'.freeze
  LIVE_HOST_NAME = 'applyforlegalaid.apps.cloud-platform-live-0.k8s.integration.dsd.io'.freeze

  def self.env
    if Rails.env.development?
      :development
    elsif Rails.env.test?
      :test
    elsif uat_host?
      :uat
    elsif staging_host?
      :staging
    elsif live_host?
      :live
    else
      raise 'Unknown Host Environment'
    end
  end

  def self.test?
    Rails.env.test?
  end

  def self.development?
    Rails.env.development?
  end

  def self.uat?
    uat_host?
  end

  def self.staging?
    staging_host?
  end

  def self.live?
    live_host?
  end

  def self.uat_host?
    UAT_HOST_REGEX.match?(ENV['HOST'])
  end

  def self.staging_host?
    STAGING_HOST_NAME == ENV['HOST']
  end

  def self.live_host?
    LIVE_HOST_NAME == ENV['HOST']
  end

  private_class_method :uat_host?, :staging_host?, :live_host?
end
