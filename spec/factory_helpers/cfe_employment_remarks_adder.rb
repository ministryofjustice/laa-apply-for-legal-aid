module FactoryHelpers
  class CFEEmploymentRemarksAdder
    def self.call(cfe_result)
      new(cfe_result).call
    end

    def initialize(cfe_result)
      @cfe_result = cfe_result
      @laa = @cfe_result.legal_aid_application
    end

    def call
      create_employment_records
      emp = @laa.reload.employments.order(:name).first
      payments = emp.employment_payments

      result_hash = @cfe_result.result_hash
      remarks = result_hash[:assessment][:remarks]
      remarks[:employment] = {}
      remarks[:employment_gross_income] = {}
      remarks[:employment_nic] = {}
      remarks[:employment_tax] = {}

      remarks[:employment][:multiple_employments] = @laa.employments.map(&:id)
      remarks[:employment_gross_income][:amount_variation] = payments.map(&:id)
      remarks[:employment_gross_income][:unknown_frequency] = payments.map(&:id)
      remarks[:employment_nic][:amount_variation] = payments.map(&:id)
      remarks[:employment_nic][:refunds] = [payments.first.id, payments.last.id]
      remarks[:employment_tax][:amount_variation] = payments.map(&:id)
      remarks[:employment_tax][:refunds] = [payments.first.id, payments.last.id]

      result_hash[:assessment][:remarks] = remarks
      @cfe_result.update!(result: result_hash.to_json)
    end

    private

    def create_employment_records
      FactoryBot.create :employment, :with_irregularities, legal_aid_application: @laa
      FactoryBot.create :employment, legal_aid_application: @laa
    end
  end
end
