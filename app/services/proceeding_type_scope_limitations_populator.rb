class ProceedingTypeScopeLimitationsPopulator
  def self.call
    new.call
  end

  def file_path
    Rails.root.join('db', 'seeds', 'legal_framework', 'proceeding_type_scope_limitations.csv').freeze
  end

  def call
    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      proceeding_type_scope_limitation =
        ProceedingTypeScopeLimitation.where(proceeding_type_id: proceeding_type_id(row),
                                            scope_limitation_id: scope_limitation_id(row)).first_or_initialize
      proceeding_type_scope_limitation.update! attributes(row)
    end
  end

  def attributes(row)
    {
      proceeding_type_id: proceeding_type_id(row),
      scope_limitation_id: scope_limitation_id(row),
      substantive_default: row[:substantive_default],
      delegated_functions_default: row[:delegated_functions_default]
    }
  end

  private

  def proceeding_type_id(row)
    ProceedingType.find_by(ccms_code: row[:proceeding_type_code]).id
  end

  def scope_limitation_id(row)
    ScopeLimitation.find_by(code: row[:scope_limitation_code]).id
  end
end
