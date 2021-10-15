# :nocov:
module DataStudio
  class ApplicationDigestController < ApiController
    def index

      applications = ApplicationDigest.order(:date_submitted)


      render json: applications
    end


  end
end
# :nocov:
