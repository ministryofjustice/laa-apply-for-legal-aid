namespace :legal_framework do
  desc 'Fixes incorrect default scope limitation for proceeding type DA003'
  task update_da003: :environment do
    da003 = ProceedingType.find_by(ccms_code: 'DA003')
    fm062 = ScopeLimitation.find_by(code: 'FM062')
    aa019 = ScopeLimitation.find_by(code: 'AA019')
    ptsl_for_fm062 = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: da003.id, scope_limitation_id: fm062.id)
    ptsl_for_aa019 = ProceedingTypeScopeLimitation.find_by(proceeding_type_id: da003.id, scope_limitation_id: aa019.id)

    ProceedingTypeScopeLimitation.transaction do
      puts 'Updating substantive_default for scope limitation FM062 to false for proceeding type DA003'
      ptsl_for_fm062.substantive_default = false
      ptsl_for_fm062.save!

      puts 'Updating substantive_default for scope limitation AA019 to true for proceeding type DA003'
      ptsl_for_aa019.substantive_default = true
      ptsl_for_aa019.save!
    end

    puts 'Update complete'
  end
end
