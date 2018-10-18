class Crypt
  SECRET = ENV.fetch('CRYPT_SECRET', '35ac2ba771c6dec')
  SALT = ENV.fetch('CRYPT_SALT', 'ddf1d042f637')

  def self.key
    @key ||= ActiveSupport::KeyGenerator.new(SECRET).generate_key(SALT, ActiveSupport::MessageEncryptor.key_len)
  end

  def decrypt(token)
    unescaped = CGI.unescape(token)
    crypt.decrypt_and_verify(unescaped)
  end

  def encrypt(text)
    token = crypt.encrypt_and_sign(text)
    CGI.escape token
  end

  private

  def crypt
    @crypt ||= ActiveSupport::MessageEncryptor.new(self.class.key)
  end
end
