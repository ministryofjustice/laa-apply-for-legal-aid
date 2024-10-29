module ClientHelper
  def means_tested_description(legal_aid_application)
    return t("generic.means_tested.no_sca") if legal_aid_application.special_children_act_proceedings?
    return t("generic.means_tested.no_under_18") if legal_aid_application.applicant.under_18?

    t("generic.yes")
  end
end
