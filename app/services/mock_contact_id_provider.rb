class MockContactIdProvider
  # If providers username is in the list of usernames, then use the contact id from there,
  # otherwise use it from the Provider record
  def self.call(provider)
    if private_beta_users.key?(provider.username)
      private_beta_users[provider.username]
    else
      provider.user_login_id
    end
  end

  def provider_beta_users
    @provider_beta_users ||= YAML.load_file
  end
end
