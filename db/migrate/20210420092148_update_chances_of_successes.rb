class UpdateChancesOfSuccesses < ActiveRecord::Migration[6.1]
  def up
    add_belongs_to :chances_of_successes, :application_proceeding_type, foreign_key: true, null: true, type: :uuid
    execute <<~SQL.squish
      UPDATE chances_of_successes cos
      SET application_proceeding_type_id = t.apt_id
      from (
               SELECT cos1.id as cos_id,
                      apt1.id as apt_id,
                      laa1.id as laa_id
               FROM chances_of_successes cos1
                        LEFT OUTER JOIN legal_aid_applications laa1 on laa1.id = cos1.legal_aid_application_id
                        LEFT OUTER JOIN application_proceeding_types apt1 on laa1.id = apt1.legal_aid_application_id
           ) t
      WHERE t.laa_id = cos.legal_aid_application_id;
    SQL
    change_column_null :chances_of_successes, :application_proceeding_type_id, false
    change_column_null :chances_of_successes, :legal_aid_application_id, true
  end

  def down
    change_column_null :chances_of_successes, :legal_aid_application_id, false
    remove_belongs_to :chances_of_successes, :application_proceeding_type
  end
end
