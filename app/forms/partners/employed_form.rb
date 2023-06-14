module Partners
  class EmployedForm < BaseEmployedForm
    form_for Partner

  private

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.partner.attributes.base.none_selected")
    end
  end
end
