class ScopeLimitationJsonBuilder
  extend NilSafeBuilder

  def initialize(scope_limitation)
    @scope_limitation = scope_limitation
  end

  attr_reader :scope_limitation

  delegate :id,
           :scope_type,
           :code,
           :meaning,
           :description,
           :hearing_date,
           :limitation_note,
           :created_at,
           :updated_at,
           to: :scope_limitation

  def as_json
    return unless scope_limitation

    {
      id:,
      scope_type:,
      code:,
      meaning:,
      description:,
      hearing_date:,
      limitation_note:,
      created_at:,
      updated_at:,
    }
  end
end
