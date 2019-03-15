module Citizens
  class AccountsController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def index
      return if !legal_aid_application.transactions_gathered? && worker_working?

      if worker_errors.any?
        @errors = worker_errors.join(', ')
      else
        legal_aid_application.update! transactions_gathered: true
        session[:worker_id] = nil
      end
      @applicant_banks = current_applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
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
