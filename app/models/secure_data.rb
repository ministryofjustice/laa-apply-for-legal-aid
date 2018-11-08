class SecureData < ApplicationRecord
  def self.create_and_store(hash)
    secure_data = new
    secure_data.store(hash)
    secure_data.save
    secure_data.id
  end

  def self.for(id)
    find(id).retrieve
  end

  def store(hash)
    self.data = JWT.encode hash, nil, 'none'
  end

  def retrieve
    JWT.decode(data, nil, false).first.symbolize_keys
  end
end
