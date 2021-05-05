class ProceedingTypeScopeLimitationsPopulator
  def self.call
    new.call
  end

  def file_path
    Rails.root.join('db/seeds/legal_framework/proceeding_type_scope_limitations.csv').freeze
  end

  def call
    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      # TODO: Delete when the allow_multiple_proceedings? flag is
      # removed. At that point, all proceedings will be seeded again
      next if ProceedingType.find_by(ccms_code: row[:proceeding_type_code]).nil?

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
    proceeding_types.find { |proceeding_type| proceeding_type.ccms_code == row[:proceeding_type_code] }.id
  end

  def scope_limitation_id(row)
    scope_limitations.find { |scope_limitation| scope_limitation.code == row[:scope_limitation_code] }.id
  end

  def proceeding_types
    @proceeding_types ||= ProceedingType.select(:id, :ccms_code).all
  end

  def scope_limitations
    @scope_limitations ||= ScopeLimitation.select(:id, :code).all
  end
end
