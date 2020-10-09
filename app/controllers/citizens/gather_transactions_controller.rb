module Citizens
  class GatherTransactionsController < CitizenBaseController
    class TrueLayerWorkerError < StandardError; end
    skip_back_history_for :index
    helper_method :error_description

    def index
      return if worker_working?

      if worker_errors.any?
        @errors = worker_errors.join(', ')
        Raven.capture_exception(TrueLayerWorkerError.new(@errors))
      else
        @worker_complete = true
      end
      reset_worker
    end

    private

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

    def error_description
      truelayer_error_description || I18n.t('citizens.gather_transactions.index.default_error')
    end

    def truelayer_error_description
      JSON.parse(worker_errors[2])&.dig('TrueLayerError', 'error_description') unless worker_errors[2].nil?
    end
  end
end
