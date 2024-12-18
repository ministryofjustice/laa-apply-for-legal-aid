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
    safe_join(ScopeLimitationDetailBuilder.call(scope_limitation), "<br>".html_safe)
  end
end
