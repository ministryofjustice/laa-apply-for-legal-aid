namespace :ccms do
  desc 'Clear CCMS submissions with stuck means reports'
  task :clear_queue, [:application_id] => :environment do |_task, args|
    include Rails.application.routes.url_helpers
    # v3
    # get the application_ids
    # delete any application.attachments where attachment_type='means_report'
    # delete any application.ccms_submission.submission_documents where document_type: "means_report"
    # run MeansReportCreator.call(legal_aid_application)
    # output url for accessing the means report e.g. service_url/application_guid/means_report
    dry_run = ENV['DRY_RUN'].nil?
    ActiveRecord::Base.logger = nil
    application_ids = if args[:application_id].nil?
                        CCMS::Submission.where("aasm_state NOT IN ('completed', 'failed')").pluck(:legal_aid_application_id)
                      else
                        [] << args[:application_id]
                      end
    application_ids.each do |laa_id|
      laa = LegalAidApplication.find(laa_id)
      attachments = laa.attachments.where(attachment_type: 'means_report')
      submission_documents = laa.ccms_submission.submission_documents.where(document_type: 'means_report')
      if dry_run
        pp "I want to delete the #{attachments.count} attachments with ids #{attachments.pluck(:id)}"
        pp "I want to delete the #{submission_documents.count} submission_documents with ids #{submission_documents.pluck(:id)}"
        pp "I would call Reports::MeansReportCreator.call for LegalAidApplication id:#{laa.id}"
        pp "I would mark LegalAidApplication id:#{laa.id} as complete"
      else
        submission_documents.delete_all
        attachments.delete_all
        Reports::MeansReportCreator.call(laa)
        laa.ccms_submission.complete!
      end
      pp "#{providers_legal_aid_application_means_report_url(laa)}?debug=true#{' would work if not in dry_run mode' if dry_run}"
    rescue StandardError => e
      puts e
      raise
    end
  end
end
