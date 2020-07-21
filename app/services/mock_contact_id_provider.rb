class MockContactIdProvider
  FILENAME = Rails.root.join('config/encrypted_private_beta_users.yml')

  # If providers username is in the list of usernames, then use the contact id from there,
  # otherwise use it from the Provider record
  def self.call(provider)
    if private_beta_users.key?(provider.username.upcase)
      private_beta_users[provider.username.upcase].to_s
    else
      provider.user_login_id
    end
  end

  def self.private_beta_users
    @private_beta_users ||= YAML.load_file(FILENAME)
  end
end
