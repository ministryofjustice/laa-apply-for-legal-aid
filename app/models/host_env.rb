class HostEnv
  def self.environment
    return Rails.env.to_sym unless Rails.env.production?

    raise "Unable to determine HostEnv from HOST_ENV envar" if host_env.nil?

    host_env
  end

  def self.host_env
    ENV.fetch("HOST_ENV", nil)&.to_sym
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

  def self.not_production?
    environment != :production
  end

  def self.staging_or_production?
    environment.in?(%i[staging production])
  end
end
