require 'csv'

class ServiceLevelPopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/legal_framework/levels_of_service.csv')

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      service_level = ServiceLevel.where(service_level_number: row[:service_level_number]).first_or_initialize
      service_level.update! row.to_h
    end
  end
end
