module ClientHelper
  def means_tested?(legal_aid_application)
    return "No, SCA application" if legal_aid_application.special_children_act_proceedings?
    return "No, client under 18" if legal_aid_application.applicant.under_18?

    "Yes"
  end
end
