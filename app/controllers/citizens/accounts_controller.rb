module Citizens
  class AccountsController < BaseController
    before_action :authenticate_applicant!

    def index
      return if worker_working?

      @errors = worker_errors.join(', ') if worker_errors.any?
      @applicant_banks = current_applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end

    private

    def worker_errors
      return [] unless worker
      return [] unless worker['errors'].present?

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
      return nil if params[:worker_id].blank?

      @worker ||= Sidekiq::Status.get_all(worker_id)
    end

    def worker_id
      @worker_id ||= params[:worker_id]
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
