module Flow
  module Steps
    module LinkedApplications
      FindLinkStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_link_application_find_link_application_path(application) },
        forward: :link_application_confirm_links,
      )
    end
  end
end
