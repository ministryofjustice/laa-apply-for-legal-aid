module Dashboard
  class ApplicantEmailJob < ActiveJob::Base
    def perform(application)
      Dashboard::SingleObject::ApplicantEmail.new(application).run
    end
  end
end
