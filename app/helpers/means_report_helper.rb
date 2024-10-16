module MeansReportHelper
  TransactionTypeItem = Struct.new(:name, :value_method, :scope, :suppress_border)

  def outgoings_detail_items
    [
      TransactionTypeItem.new(:housing, :moe_housing, "outgoing", false),
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
    items.append(TransactionTypeItem.new(:partner_allowance, :partner_allowance, "deductions", false)) if legal_aid_application.applicant.has_partner_with_no_contrary_interest?
    items.append(TransactionTypeItem.new(:disregarded_state_benefits, :disregarded_state_benefits, "deductions", true)) unless legal_aid_application.uploading_bank_statements?
    items
  end

  def partner_exclude_items
    %i[dependants_allowance partner_allowance]
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
end
