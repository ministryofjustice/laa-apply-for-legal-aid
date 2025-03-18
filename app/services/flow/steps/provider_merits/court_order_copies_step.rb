module Flow
  module Steps
    module ProviderMerits
      CourtOrderCopiesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_court_order_copy_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: lambda { |_application, copy_of_court_order|
          if copy_of_court_order
            :uploaded_evidence_collections
          else
            :check_merits_answers
          end
        },
      )
    end
  end
end
