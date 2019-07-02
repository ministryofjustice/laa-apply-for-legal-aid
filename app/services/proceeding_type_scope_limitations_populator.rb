class ProceedingTypeScopeLimitationsPopulator
  def self.call
    new.call
  end

  def file_path
    Rails.root.join('db', 'seeds', 'legal_framework', 'proceeding_type_scope_limitations.csv').freeze
  end

  def call
    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      proceeding_type_scope_limitation = ProceedingTypeScopeLimitation.new
      proceeding_type_scope_limitation.update! attributes(row)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error e.message
    end
  end

  def attributes(row)
    {
      proceeding_type_id: ProceedingType.find_by(ccms_code: row[:proceeding_type_code]).id,
      scope_limitation_id: ScopeLimitation.find_by(code: row[:scope_limitation_code]).id,
      substantive_default: row[:substantive_default],
      delegated_functions_default: row[:delegated_functions_default]
    }
  end
end
