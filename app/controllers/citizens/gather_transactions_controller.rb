module Citizens
  class GatherTransactionsController < CitizenBaseController
    class TrueLayerWorkerError < StandardError; end
    skip_back_history_for :index

    def index
      I18n.locale = session[:locale]
      return if worker_working?

      if worker_errors.any?
        @error_decoder = TrueLayerErrorDecoder.new(worker_errors)
        Sentry.capture_exception(TrueLayerWorkerError.new(@errors))
        reset_worker
        render :display_error
      else
        reset_worker
        @worker_complete = true
      end
    end

    private

    def authenticate_with_devise
      restored_session = OauthSessionSaver.get(current_applicant.id)
      restored_session.each { |k, v| session[k] = v }
      OauthSessionSaver.destroy!(current_applicant.id)
      authenticate_applicant!
    end

    def worker_errors
      return [] unless worker && worker['errors'].present?

      @worker_errors ||= JSON.parse(worker['errors'])
    end

    def worker_working?
      @worker_working ||= worker_status.in? %i[queued working]
    end

    def worker_status
      return nil unless worker && worker['status']

      worker['status'].to_sym
    end

    def worker
      @worker ||= Sidekiq::Status.get_all(worker_id)
    end

    def worker_id
      session[:worker_id] ||= start_worker_to_get_transactions
    end

    def start_worker_to_get_transactions
      legal_aid_application.set_transaction_period
      ImportBankDataWorker.perform_async(legal_aid_application.id)
    end

    def reset_worker
      session[:worker_id] = nil
    end
  end
end
