module Flow
  module Steps
    module ProviderMerits
      UploadedEvidenceCollectionsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_uploaded_evidence_collection_path(application) },
        forward: :check_merits_answers,
      )
    end
  end
end
