class CreateApplicationDigests < ActiveRecord::Migration[6.1]
  SQL = <<~EOSQL.freeze
    CREATE MATERIALIZED VIEW application_digests as
      SELECT
             laa.id,
             f.name,
             laa.created_at::date as date_started,
             laa.merits_submitted_at::date as date_submitted,
             (laa.merits_submitted_at::date - laa.merits_submitted_at::date) + 1 as days_to_submission,
             sm.aasm_state as state,
             CASE WHEN sm.aasm_state = 'use_ccms' THEN true
                  ELSE false
             END as use_ccms,
             sm.ccms_reason,
             CASE WHEN laa.merits_submitted_at IS NULL and laa.updated_at::date - interval '14 day' < current_date THEN true
                  ELSE false
             END as abandoned,
             (SELECT COUNT(*) from application_proceeding_types apt WHERE apt.legal_aid_application_id = laa.id) as num_proceedings,
             CASE WHEN (
                          SELECT count(*)
                          FROM proceeding_types pt
                          INNER JOIN application_proceeding_types apt ON (pt.id = apt.proceeding_type_id)
                          INNER JOIN legal_aid_applications laa on (laa.id = apt.legal_aid_application_id)
                          AND pt.ccms_code LIKE 'DA%'
                      ) > 0 THEN true
                  ELSE false
             END as domestic_abuse,
             CASE WHEN (
                           SELECT count(*)
                           FROM proceeding_types pt
                           INNER JOIN application_proceeding_types apt ON (pt.id = apt.proceeding_type_id)
                           INNER JOIN legal_aid_applications laa1 on (laa1.id = apt.legal_aid_application_id)
                           AND pt.ccms_code LIKE 'SE%'
                           WHERE laa1.id = laa.id
                       ) > 0 THEN true
                  ELSE false
             END as section8,

             CASE WHEN (
                      SELECT COUNT(*)
                      FROM benefit_check_results bcr
                      WHERE bcr.legal_aid_application_id = laa.id
                      AND bcr.result = 'Yes') > 0 THEN true
                  ELSE false
             END as dwp_passported,

             CASE WHEN (
                      SELECT COUNT(*)
                      FROM dwp_overrides dwp
                      WHERE dwp.legal_aid_application_id = laa.id
                      AND dwp.has_evidence_of_benefit = 't') > 0 THEN true
                  ELSE false
          END as dwp_overridden



      FROM legal_aid_applications laa
           INNER JOIN providers p on (p.id = laa.provider_id)
           INNER JOIN firms f on (p.firm_id = f.id)
           INNER JOIN state_machine_proxies as sm on laa.id = sm.legal_aid_application_id
  EOSQL

  def up
    execute SQL
  end

  def down
    execute 'DROP MATERIALIZED VIEW application_digests'
  end
end
