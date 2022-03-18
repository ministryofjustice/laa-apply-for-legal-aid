namespace :employment do
  desc "Adds remarks to the first cfe_result record in the database"
  task remarks: :environment do
    cfe_result = CFE::V4::Result.first
    laa = cfe_result.legal_aid_application
    emp = laa.employments.order(:name).first
    payments = emp.employment_payments

    result_hash = cfe_result.result_hash
    remarks = result_hash[:assessment][:remarks]
    remarks[:employment][:multiple_employments] = laa.employments.map(&:id)
    remarks[:employment_gross_income] = {}
    remarks[:employment_nic] = {}
    remarks[:employment_tax] = {}
    remarks[:employment_gross_income][:amount_variation] = payments.map(&:id)
    remarks[:employment_gross_income][:unknown_frequency] = payments.map(&:id)
    remarks[:employment_nic][:amount_variation] = payments.map(&:id)
    remarks[:employment_nic][:refunds] = [payments.first.id, payments.last.id]
    remarks[:employment_tax][:amount_variation] = payments.map(&:id)
    remarks[:employment_tax][:refunds] = [payments.first.id, payments.last.id]

    result_hash[:assessment][:remarks] = remarks
    cfe_result.update!(result: result_hash.to_json)
  end
end
