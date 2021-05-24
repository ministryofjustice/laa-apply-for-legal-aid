class DFDatesUpdater
  def run
    laa_ids = LegalAidApplication.where.not(substantive_application_deadline_on: nil).pluck(:id)
    laa_ids.each do |laa_id|
      laa = LegalAidApplication.find laa_id
      df_date = WorkingDayCalculator.call(working_days: -20, from: laa.substantive_application_deadline_on)
      reminder_mail = ScheduledMailing.where(mailer_klass: 'SubmitApplicationReminderMailer', legal_aid_application_id: laa_id).first
      reported_date = reminder_mail&.created_at || df_date
      laa.application_proceeding_types.each do |apt|
        apt.update!(used_delegated_functions_on: df_date, used_delegated_functions_reported_on: reported_date)
      end
      puts "Legal Aid Application id: #{laa_id}  deadline: #{laa.substantive_application_deadline_on.strftime('%F')} DF dates updated to: #{df_date.strftime('%F')} (used), #{reported_date.strftime('%F')} (reported)"
    end
  end
end


DFDatesUpdater.new.run
