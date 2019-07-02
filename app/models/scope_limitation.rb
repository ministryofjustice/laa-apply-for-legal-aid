require 'csv'

class ScopeLimitation < ApplicationRecord
  validates :code, :meaning, :description, presence: true
  validates :substantive, :delegated_functions, inclusion: [true, false]

  def self.populate
    file_path = Rails.root.join('db', 'seeds', 'scope_limitations.csv')

    CSV.read(file_path, headers:true, header_converters: :symbol).each do |row|
      scope_limitation = ScopeLimitation.where(code: row[:code]).first_or_initialize
      scope_limitation.update! row.to_h
    end
  end
end
