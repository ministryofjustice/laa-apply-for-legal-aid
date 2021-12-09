require 'csv'

class DocumentCategoryPopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/document_categories.csv').freeze

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      document_category = DocumentCategory.where(name: row[:name]).first_or_initialize
      document_category.update! row.to_h
    end
  end
end
