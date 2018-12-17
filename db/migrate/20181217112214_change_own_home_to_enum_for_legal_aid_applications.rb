class ChangeOwnHomeToEnumForLegalAidApplications < ActiveRecord::Migration[5.2]
  def up
    change_column(
      :legal_aid_applications,
      :own_home,
      <<SQL
        integer USING CASE WHEN own_home='mortgage' THEN 0
                           WHEN own_home='owned_outright' THEN 1
                           WHEN own_home='no' THEN 2
                           ELSE NULL
                      END

SQL
    )
  end

  def down
    change_column(
      :legal_aid_applications,
      :own_home,
      <<SQL
        varchar USING CASE WHEN own_home=0 THEN 'mortgage'
                           WHEN own_home=1 THEN 'owned_outright'
                           WHEN own_home=2 THEN 'no'
                           ELSE NULL
                      END
SQL
    )
  end
end
