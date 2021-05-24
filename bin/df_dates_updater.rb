class DFDatesUpdater
  def run
    apts = ApplicationProceedingType.where(used_delegated_functions_on: nil)
    apts.each { |apt| process_apt(apt) }
  end

  private

  def process_apt(apt)
    laa = apt.legal_aid_application
    return if laa.substantive_application_deadline_on.nil?

    update_apt(apt, laa)
  end

  def update_apt(apt, laa)
    df_date = WorkingDayCalculator.call(working_days: -20, from: laa.substantive_application_deadline_on)
    reminder_mail = ScheduledMailing.where(mailer_klass: 'SubmitApplicationReminderMailer', legal_aid_application_id: laa.id).first
    reported_date = reminder_mail&.created_at || df_date
    apt.update!(used_delegated_functions_on: df_date, used_delegated_functions_reported_on: reported_date)
    # rubocop:disable Layout/LineLength
    puts "Legal Aid Application id: #{laa.id}  deadline: #{laa.substantive_application_deadline_on.strftime('%F')} DF dates updated to: #{df_date.strftime('%F')} (used), #{reported_date.strftime('%F')} (reported)"
    # rubocop:enable Layout/LineLength
  end
end

DFDatesUpdater.new.run
