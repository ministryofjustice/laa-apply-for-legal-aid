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
    scope_limitations = proceeding.scope_limitations
                                  .where(scope_type:)
                                  .map { |scope_limitation| scope_limitation_details(scope_limitation) }

    safe_join(scope_limitations, "<br><br>".html_safe)
  end

private

  def scope_limitation_details(scope_limitation)
    sole_scope_limitation = scope_limitation.proceeding.scope_limitations.where(scope_type: scope_limitation.scope_type).count.eql?(1)
    scope_limitation_meaning = if sole_scope_limitation
                                 scope_limitation.meaning
                               else
                                 "<span class=\"single-scope-limit-heading\">#{scope_limitation.meaning}</span>".html_safe
                               end
    scope_limitation_details = [scope_limitation_meaning, scope_limitation.description]

    if scope_limitation.hearing_date && scope_limitation.description.exclude?(scope_limitation.hearing_date.to_s)
      scope_limitation_details[1] = "#{scope_limitation.description} #{scope_limitation.hearing_date}"
    elsif scope_limitation.limitation_note
      scope_limitation_details << "Note: #{scope_limitation.limitation_note}"
    end

    safe_join(scope_limitation_details, "<br>".html_safe)
  end
end
