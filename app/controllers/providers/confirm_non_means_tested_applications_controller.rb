module Providers
  class ConfirmNonMeansTestedApplicationsController < ProviderBaseController
    include ApplicantDetailsCheckable
    include CFEResultMockable
    include BenefitCheckSkippable

    def show
      details_checked! unless details_checked?
    end

    def update
      mark_as_benefit_check_skipped!("no_means_test_required")
      mark_as_cfe_result_skipped!

      legal_aid_application.provider_enter_merits! unless draft_selected? || legal_aid_application.provider_entering_merits?
      continue_or_draft
    end
  end
end
