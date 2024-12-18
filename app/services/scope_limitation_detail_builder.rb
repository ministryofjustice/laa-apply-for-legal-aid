class ScopeLimitationDetailBuilder
  attr_reader :scope_limitation

  def self.call(scope_limitation)
    new(scope_limitation).call
  end

  def initialize(scope_limitation)
    @scope_limitation = scope_limitation
  end

  def call
    [scope_limitation_meaning, scope_limitation_description, scope_limitation_additional_notes].compact_blank!
  end

private

  def scope_limitation_meaning
    if sole_scope_limitation?
      scope_limitation.meaning
    else
      "<span class=\"single-scope-limit-heading\">#{scope_limitation.meaning}</span>".html_safe
    end
  end

  def scope_limitation_description
    if hearing_date_addition_needed?
      "#{scope_limitation.description} #{scope_limitation.hearing_date}"
    else
      scope_limitation.description
    end
  end

  def scope_limitation_additional_notes
    "Note: #{scope_limitation.limitation_note}" if scope_limitation.limitation_note
  end

  def hearing_date_addition_needed?
    scope_limitation.hearing_date && scope_limitation.description.exclude?(scope_limitation.hearing_date.to_s)
  end

  def sole_scope_limitation?
    @sole_scope_limitation ||= scope_limitation.proceeding.scope_limitations.where(scope_type: scope_limitation.scope_type).count.eql?(1)
  end
end
