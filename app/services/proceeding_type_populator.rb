require 'csv'

class ProceedingTypePopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/proceeding_types.csv').freeze

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      proceeding_type = ProceedingType.where(code: row[:code]).first_or_initialize
      proceeding_type.update! row.to_h
    end
  end
end
