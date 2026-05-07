module Editing
  class FinancialAssessmentCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      # If there is data that ensures we have truelayer data then we should preserve that data but we
      # need to have the system skip the pages asking the provider to send the email again as we already
      # have that data.

      destroy_open_banking_flow_data!

      destroy_bank_statement_flow_data!
    end

  private

    attr_reader :legal_aid_application

    def destroy_open_banking_flow_data!
      destroy_citizen_shared_data!
      destroy_provider_collating_of_citizen_data!
    end

    def destroy_citizen_shared_data!
      legal_aid_application.applicant.update!(email: nil, encrypted_true_layer_token: nil)
      legal_aid_application.update!(open_banking_consent: nil, open_banking_consent_choice_at: nil, completed_at: nil, declaration_accepted_at: nil)

      # bank provider destruction should chain to bank_account_holders and bank_accounts if they exist and bank_transactions through bank accounts
      legal_aid_application.applicant&.bank_providers&.each(&:destroy!)

      # destroy waiting emails to remind provider to complete application following citizen sharing of bank transactions
      # destroy waiting emails to remind the citizen to share their bank transactions
      legal_aid_application
        .scheduled_mailings
        .where(mailer_klass: [SubmitProviderFinancialReminderMailer, SubmitCitizenFinancialReminderMailer],
               status: :waiting).find_each(&:cancel!)
    end

    def destroy_provider_collating_of_citizen_data!
      legal_aid_application.update!(no_credit_transaction_types_selected: nil, no_debit_transaction_types_selected: nil)

      # destroy types of income/credits and outgoings/debits selected by the provider
      # NOTE: there is an after_commit hook on the LegalAidApplicationTransactionType model
      # that should destroy any cash transactions with the transaction type and nullify the transaction
      # type on any bank transactions (but which we want to delete the bank transactions anyway?!).
      legal_aid_application.legal_aid_application_transaction_types.find_each(&:destroy!)

      # TODO: may not be needed, see note above on after_commit hook on the LegalAidApplicationTransactionType model, but added for completeness
      # TODO: may not be needed because these are also destroyed as part of "bank statement upload flow"
      legal_aid_application.cash_transactions.find_each(&:destroy!)

      # TODO: should already be deleted due to cascading delete on bank_providers but added for completeness, remove if unnecessary after testing
      legal_aid_application.bank_transactions.find_each(&:destroy!)

      # TODO: may not be needed because these are also destroyed as part of "bank statement upload flow"
      legal_aid_application.regular_transactions.each(&:destroy!)
    end

    def destroy_bank_statement_flow_data!
      destroy_financial_assessment_data!
      update_applicant_data!
      update_partner_data!
      update_legal_aid_application_data!
    end

    # TODO: truelayer/open banking data should also be removed, but this is not yet implemented. ticket?
    def destroy_financial_assessment_data!
      # "bank_statements"
      legal_aid_application.attachments.bank_statement_evidence&.each(&:destroy!)
      legal_aid_application.attachments.part_bank_state_evidence&.each(&:destroy!)

      # "state_benefits", "add_other_state_benefits", "remove_state_benefits", "regular_incomes", "regular_outgoings"
      legal_aid_application.regular_transactions.each(&:destroy!)

      # "cash_income", "cash_outgoing"
      legal_aid_application.cash_transactions.each(&:destroy!)

      # "dependants", "has_other_dependants", "remove_dependants"
      legal_aid_application.dependants.each(&:destroy!)
    end

    # TODO: employment attributes and no_cash_income|outgoings attributes should be moved to the applicant for consistency. ticket?
    def update_legal_aid_application_data!
      # "substantive_application", "does-client-use-online-banking", "extra_employment_information", "extra_employment_information_details", "full_employment_details"
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
