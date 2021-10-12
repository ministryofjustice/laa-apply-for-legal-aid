# :nocov:
module DataStudio
  class ApplicationDigestController < ApiController
    def index
      render json: ApplicationDigest.limit(10)
    end
  end
end
# :nocov:
