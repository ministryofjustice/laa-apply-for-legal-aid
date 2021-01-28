class ScopeLimitationsPopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/legal_framework/scope_limitations.csv')

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      scope_limitation = ScopeLimitation.where(code: row[:code]).first_or_initialize
      scope_limitation.update! row.to_h
    end
  end
end
