module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @source_application = @legal_aid_application.copy_case? ? LegalAidApplication.find(legal_aid_application.copy_case_id) : @legal_aid_application
      @read_only = true
      set_transaction_types
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports!
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end

  private

    def set_transaction_types
      @credit_transaction_types = if legal_aid_application.client_uploading_bank_statements?
                                    TransactionType.credits.without_disregarded_benefits.without_benefits
                                  else
                                    TransactionType.credits.without_housing_benefits
                                  end

      @debit_transaction_types = TransactionType.debits
    end
  end
end
