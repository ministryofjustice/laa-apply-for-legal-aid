module Citizens
  class AccountsController < CitizenBaseController
    class TrueLayerWorkerError < StandardError; end
    skip_back_history_for :gather

    def index
      @applicant_banks = current_applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end

    def gather
      return if worker_working?

      if worker_errors.any?
        @errors = worker_errors.join(', ')
        Raven.capture_exception(TrueLayerWorkerError.new(@errors))
      else
        session[:worker_id] = nil
        redirect_to action: :index
      end
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
  end
end
