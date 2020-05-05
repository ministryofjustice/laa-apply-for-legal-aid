module Providers
  class MeansSummariesController < ProviderBaseController
    skip_back_history_for :gather

    def show
      legal_aid_application.provider_check_citizens_means_answers! unless legal_aid_application.provider_checking_citizens_means_answers?
    end

    def update
      unless draft_selected? || legal_aid_application.provider_checked_citizens_means_answers?
        redirect_to(problem_index_path) && return unless check_financial_eligibility

        legal_aid_application.provider_checked_citizens_means_answers!
      end
      continue_or_draft
    end

    def gather
      if worker_working?
        render :gather
      else
        legal_aid_application.complete_bank_transaction_analysis!

        if worker_errors.any?
          @errors = worker_errors.join(', ')
        else
          legal_aid_application.gathering_transactions_jid = nil
          redirect_to action: :show
        end
      end
    end

    private

    helper_method :worker_id

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
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
      legal_aid_application.update_attribute(:gathering_transactions_jid, start_worker_to_analyse_bank_transactions) unless legal_aid_application.gathering_transactions_jid
      legal_aid_application.gathering_transactions_jid
    end

    def start_worker_to_analyse_bank_transactions
      legal_aid_application.set_transaction_period
      BankTransactionsAnalyserWorker.perform_async(legal_aid_application.id) || nil
    end
  end
end
