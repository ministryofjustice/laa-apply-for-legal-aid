# To run this task, use the following command: rake migrate:applicant_entering_means
namespace :migrate do
  desc "AP-7504 populate autogranted column for submitted applications"
  task :migrate_autogranted, [:dry_run] => :environment do |task, args|
    dry_run = args.dry_run != "false"
    Rails.logger.info "#{task}: dry_run=#{dry_run}"

    submitted_applications = LegalAidApplication.where.not(merits_submitted_at: nil).where(autogranted: nil)
    submitted_applications_count = submitted_applications.count

    Rails.logger.info "#{task}:Populating autogranted for submitted applications"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "#{task}:submitted applications count: #{submitted_applications_count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    submitted_applications.in_batches do |batch|
      batch.each do |application|
        autogranted = if application.merits_submitted_at < Date.parse("2026-06-22")
                        legacy_auto_grant_special_children_act?(application)
                      else
                        Autograntable.call(application)
                      end
        next if dry_run

        application.autogranted = autogranted
        application.save!(touch: false)
      end
    end

    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "#{task}: #{submitted_applications_count} applications updated"
    Rails.logger.info "#{task}: #{LegalAidApplication.where.not(merits_submitted_at: nil).where(autogranted: nil).count} submitted applications without autogranted value"
    Rails.logger.info "----------------------------------------"
  end
end

def legacy_auto_grant_special_children_act?(legal_aid_application)
  legal_aid_application.special_children_act_proceedings? && legacy_auto_grant_exclusions?(legal_aid_application)
end

def legacy_auto_grant_exclusions?(legal_aid_application)
  # If any of these are true then auto-granting should not occur
  # This list is not definitive, it is accurate for the initial release of SCA, Oct 2024
  # e.g. when Apply starts handling high-cost cases we could add a test for claims > £25,000
  [
    legal_aid_application.special_children_act_related_proceedings?,
    legal_aid_application.client_court_ordered_parental_responsibility?,
    legal_aid_application.client_parental_responsibility_agreement?,
    legacy_special_children_act_child_subject_over_17?(legal_aid_application),
  ].none?
end

def legacy_special_children_act_child_subject_over_17?(legal_aid_application)
  legacy_sca_care_order_or_supervision_order_child_subject?(legal_aid_application) && legal_aid_application.applicant.over_17?
end

def legacy_sca_care_order_or_supervision_order_child_subject?(legal_aid_application)
  legal_aid_application.proceedings.any? { |proceeding| proceeding.ccms_code.in?(%w[PB057 PB059]) && proceeding.client_involvement_type_ccms_code.eql?("W") }
end
