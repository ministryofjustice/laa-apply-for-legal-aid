require 'csv'

class ProceedingTypePopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/legal_framework/proceeding_types.csv').freeze

    default_service_level = ServiceLevel.find_by!(service_level_number: 3)

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      proceeding_type = ProceedingType.where(code: row[:code]).first_or_initialize
      proceeding_type.update! row.to_h.merge(default_service_level_id: default_service_level.id)
    end
  end
end
