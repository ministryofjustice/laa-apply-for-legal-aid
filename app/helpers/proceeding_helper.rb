module ProceedingHelper
  def position_in_array(proceeding)
    application = proceeding.legal_aid_application
    proceedings = application.proceedings.in_order_of_addition
    if proceedings.count > 1
      position = proceedings.pluck(:id).find_index(proceeding.id) + 1
      I18n.t("providers.proceeding_loop.multi_proceeding", position:, total: proceedings.count)
    elsif proceedings.count == 1
      I18n.t("providers.proceeding_loop.single_proceeding")
    end
  end

  def scope_limits(proceeding, scope_type)
    scope_limits = []
    proceeding.scope_limitations.where(scope_type:).each do |scope_limitation|
      scope_limits << scope_limitation_meaning(scope_limitation)
    end
    scope_limits
  end

private

  def scope_limitation_meaning(scope_limitation)
    scope_limitation_meaning = scope_limitation.meaning
    if scope_limitation.hearing_date
      scope_limitation_meaning += "<br>Date: #{scope_limitation.hearing_date}"
    elsif scope_limitation.limitation_note
      scope_limitation_meaning += "<br>Note: #{scope_limitation.limitation_note}"
    end
    sanitize(scope_limitation_meaning)
  end
end
