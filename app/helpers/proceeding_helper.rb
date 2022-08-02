module ProceedingHelper
  def position_in_array(proceeding)
    application = proceeding.legal_aid_application
    proceedings = application.proceedings.in_order_of_addition
    if proceedings.count > 1
      position = proceedings.pluck(:id).find_index(proceeding.id) + 1
      I18n.t("providers.delegated_functions.show.multi_proceeding", position:, total: proceedings.count)
    elsif proceedings.count == 1
      I18n.t("providers.delegated_functions.show.single_proceeding")
    end
  end
end
