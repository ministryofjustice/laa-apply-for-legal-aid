# :nocov:
module DataStudio
  class ApplicationDigestController < ApiController
    def index
      render json: ApplicationDigest.all.to_json
    end
  end
end
# :nocov:
