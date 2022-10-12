module MeansReportHelper
  TransactionTypeItem = Struct.new(:name, :value_method, :scope, :suppress_border, :addendum)

  def outgoings_detail_items(legal_aid_application)
    [
      TransactionTypeItem.new(:housing, :moe_housing, "outgoing", false, housing_payment_addendum(legal_aid_application)),
      TransactionTypeItem.new(:childcare, :moe_childcare, "outgoing", false),
      TransactionTypeItem.new(:maintenance_out, :moe_maintenance_out, "outgoing", false),
      TransactionTypeItem.new(:legal_aid, :moe_legal_aid, "outgoing", true),
    ]
  end

  def income_detail_items(legal_aid_application)
    items = non_employed_income_detail_items
    items.prepend(*employed_income_detail_items) if legal_aid_application.applicant.employed?
    items
  end

  def deductions_detail_items(legal_aid_application)
    items = [TransactionTypeItem.new(:dependants_allowance, :dependants_allowance, "deductions", false)]
    items.append(TransactionTypeItem.new(:disregarded_state_benefits, :disregarded_state_benefits, "deductions", true)) unless legal_aid_application.using_enhanced_bank_upload?
    items
  end

private

  def employed_income_detail_items
    [
      TransactionTypeItem.new(:employment, :employment_income_gross_income, "income", false),
      TransactionTypeItem.new(:income_tax, :employment_income_tax, "income", false),
      TransactionTypeItem.new(:national_insurance, :employment_income_national_insurance, "income", false),
      TransactionTypeItem.new(:fixed_employment_deduction, :employment_income_fixed_employment_deduction, "income", false),
    ]
  end

  def non_employed_income_detail_items
    [
      TransactionTypeItem.new(:benefits, :monthly_state_benefits, "income", false),
      TransactionTypeItem.new(:family_help, :mei_friends_or_family, "income", false),
      TransactionTypeItem.new(:maintenance_in, :mei_maintenance_in, "income", false),
      TransactionTypeItem.new(:property_or_lodger, :mei_property_or_lodger, "income", false),
      TransactionTypeItem.new(:student_loan, :mei_student_loan, "income", false),
      TransactionTypeItem.new(:pension, :mei_pension, "income", true),
    ]
  end

  def housing_payment_addendum(legal_aid_application)
    t("shared.means_report.item.outgoing.housing_addendum") if legal_aid_application.using_enhanced_bank_upload?
  end
end
