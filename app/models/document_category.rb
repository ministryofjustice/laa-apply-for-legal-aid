class DocumentCategory < ApplicationRecord
  def self.populate
    DocumentCategoryPopulator.call
  end
end
