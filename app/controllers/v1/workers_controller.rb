module V1
  class WorkersController < ApiController
    def show
      render json: {
        status: worker['status'],
        errors: worker['errors']
      }
    end

    private

    def worker
      @worker ||= Sidekiq::Status.get_all(worker_id)
    end

    def worker_id
      params[:id]
    end
  end
end
