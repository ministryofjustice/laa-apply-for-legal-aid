module Editing
  class FinancialAssessmentCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      destroy_financial_assessment_data!
      update_applicant_data!
      update_partner_data!
      update_legal_aid_application_data!
    end

  private

    attr_reader :legal_aid_application

    def destroy_financial_assessment_data!
      # "bank_statements"
      legal_aid_application.attachments.bank_statement_evidence.each(&:destroy!)
      legal_aid_application.attachments.part_bank_state_evidence.each(&:destroy!)

      # "state_benefits", "add_other_state_benefits", "remove_state_benefits", "regular_incomes", "regular_outgoings"
      legal_aid_application.regular_transactions.each(&:destroy!)

      # "cash_income", "cash_outgoing"
      legal_aid_application.cash_transactions.each(&:destroy!)

      # "dependants", "has_other_dependants", "remove_dependants"
      legal_aid_application.dependants.each(&:destroy!)
    end

    def update_legal_aid_application_data!
      # "substantive_application", "does-client-use-online-banking", "extra_employment_information", "extra_employment_information_details", "full_employment_details"
      #
      # TODO: employment data, no_cash_income|outgoings should be moved to the applicant for consistency. ticket?
      legal_aid_application&.update!(
        extra_employment_information: nil,
        extra_employment_information_details: nil,
        full_employment_details: nil,
        substantive_application: nil,
        provider_received_citizen_consent: nil,
        no_cash_income: nil,
        no_cash_outgoings: nil,
        no_credit_transaction_types_selected: nil,
        no_debit_transaction_types_selected: nil,
        open_banking_consent: nil,
        open_banking_consent_choice_at: nil,
        applicant_in_receipt_of_housing_benefit: nil,
        has_dependants: nil,
      )
    end

    def update_applicant_data!
      # "applicant_employed", "receives_state_benefits", "student_finance"
      legal_aid_application.applicant&.update!(
        employed: nil,
        self_employed: nil,
        armed_forces: nil,
        receives_state_benefits: nil,
        student_finance: nil,
        student_finance_amount: nil,
      )
    end

    def update_partner_data!
      # "[partner/]employed", "full_employment_details", "employment_incomes", "unexpected_employment_incomes", "student_finance"
      legal_aid_application.partner&.update!(
        employed: nil,
        self_employed: nil,
        armed_forces: nil,
        extra_employment_information: nil,
        extra_employment_information_details: nil,
        full_employment_details: nil,
        receives_state_benefits: nil,
        no_cash_income: nil,
        no_cash_outgoings: nil,
        student_finance: nil,
        student_finance_amount: nil,
      )
    end
  end
end
