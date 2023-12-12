module Partners
  class EmployedForm < BaseEmployedForm
    form_for Partner

  private

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.partner.attributes.base.none_selected")
    end

    def error_message_for_none_and_another_option_selected
      I18n.t("activemodel.errors.models.applicant.attributes.base.none_and_another_option_selected")
    end
  end
end
