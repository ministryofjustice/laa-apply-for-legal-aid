class Healthcheck
  def self.perform
    new.call
  end

  def call
    { database: database_alive? }
  end

  private

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end
end
